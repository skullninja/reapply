//
//  StoreViewController.swift
//  SPFReminder
//
//  Created by Dave Peck on 5/8/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit
import iCarousel
import AlamofireImage
import Firebase

class StoreViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnReview: UIButton!
    @IBOutlet weak var btnPurchase: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var carouselContainerView: UIView!
    @IBOutlet weak var ingredientListContainerView: UICollectionView!
    
    @IBOutlet weak var lblSPF: UILabel!
    @IBOutlet weak var lblBrand: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnMoreInfo: UIButton!
    
    let productCarousel = iCarousel(frame: .zero)
    
    let defaultHeaderImage = UIImage(named: "default")
    let timerHeaderImage = UIImage(named: "timer")
    let nightHeaderImage = UIImage(named: "night")
    
    var startingIndex: Int = 0
    var recommendedProduct: Bool = false
    
    private var currentProduct: NSDictionary {
        let index = productCarousel.currentItemIndex
        return ProductService.shared.products[index] as? NSDictionary ?? NSDictionary()
    }
    
    static func presentForProduct(product: Any, viewController: UIViewController) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController") as? StoreViewController {
            storeVC.startingIndex = ProductService.shared.indexForProduct(product)
            storeVC.recommendedProduct = true
            storeVC.modalPresentationStyle = .fullScreen
            viewController.present(storeVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (recommendedProduct){
            productCarousel.isScrollEnabled = false
            btnPrevious.isHidden = true
            btnNext.isHidden = true
        }
        
        //TODO: Refactor
        if ReminderService.shared.isRunning {
            backgroundImageView.image = timerHeaderImage
        } else if let uvIndex = ForecastService.shared.currentUVIndex,
            uvIndex < 1 {
            backgroundImageView.image = nightHeaderImage
        } else {
            backgroundImageView.image = defaultHeaderImage
        }
        
        btnReview.clipsToBounds = true
        btnReview.layer.cornerRadius = 8.0
        btnReview.layer.borderColor = UIColor.colorFromHex(0xF37225).cgColor
        btnReview.layer.borderWidth = 1.0
        btnReview.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        
        btnPurchase.clipsToBounds = true
        btnPurchase.layer.cornerRadius = 8.0
        btnPurchase.layer.borderColor = UIColor.colorFromHex(0xF37225).cgColor
        btnPurchase.layer.borderWidth = 1.0
        btnPurchase.setTitleColor(UIColor.colorFromHex(0xF37225), for: .normal)
        btnPurchase.backgroundColor = .clear
        btnPurchase.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btnPurchase.titleLabel?.adjustsFontSizeToFitWidth = true
        
        carouselContainerView.translatesAutoresizingMaskIntoConstraints = false
        carouselContainerView.addSubview(productCarousel)
        
        productCarousel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        productCarousel.frame = carouselContainerView.bounds
        productCarousel.topAnchor.constraint(equalTo: carouselContainerView.topAnchor).isActive = true
        productCarousel.leftAnchor.constraint(equalTo: carouselContainerView.leftAnchor).isActive = true
        productCarousel.bottomAnchor.constraint(equalTo: carouselContainerView.bottomAnchor).isActive = true
        productCarousel.rightAnchor.constraint(equalTo: carouselContainerView.rightAnchor).isActive = true
        
        productCarousel.delegate = self
        productCarousel.dataSource = self
        productCarousel.isPagingEnabled = true
        productCarousel.type = .invertedTimeMachine
        productCarousel.reloadData()
        productCarousel.scrollToItem(at: self.startingIndex, animated: false)
        
        ingredientListContainerView.register(IngredientCollectionViewCell.self, forCellWithReuseIdentifier: "ingredient")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4.0
        ingredientListContainerView.collectionViewLayout = layout
        ingredientListContainerView.delegate = self
        ingredientListContainerView.dataSource = self
        ingredientListContainerView.showsHorizontalScrollIndicator = false
        
        updateProductDisplay(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.setScreenName("store", screenClass: "StoreViewController")
    }
    
    private func updateProductDisplay(animated: Bool) {
        if let price = currentProduct["price"] as? String,
            let retailer = currentProduct["retailer"] as? String {
            btnPurchase.setTitle(String(format: "Buy on %@ for %@", retailer, price), for: .normal)
        } else {
            btnPurchase.setTitle("Buy Now", for: .normal)
        }
        if let name = currentProduct["name"] as? String,
            let brand = currentProduct["brand"] as? String,
            let spf = currentProduct["spf"] as? Int {
            
            lblName.text = name
            lblBrand.text = brand.uppercased()
            lblSPF.text = "SPF \(spf)"
        } else {
            lblSPF.text = ""
            lblBrand.text = "REAPPLY"
            lblName.text = "Recommended Sunscreen"
        }
        if let reviewLink = currentProduct["reviewUrl"] as? String,
            let _ = URL(string: reviewLink) {
            btnReview.isHidden = false
        } else {
            btnReview.isHidden = true
        }
        
        if (recommendedProduct){
                Analytics.logEvent(AnalyticsEvents.quizRecommendedProduct, parameters: [
                             AnalyticsParameterItemName: "product_name",
                             AnalyticsParameterItemID: currentProduct["name"] as? String ?? "none"
                             ])
            
        }
        
        ingredientListContainerView.reloadData()
    }
    
    @IBAction func previousProductAction(_ sender: Any) {
        
        guard recommendedProduct == false else { return }
        
        guard productCarousel.numberOfItems > 1, !productCarousel.isScrolling else { return }
        productCarousel.scrollToItem(at: productCarousel.currentItemIndex - 1, duration: 1.0)
    }
    
    @IBAction func nextProductAction(_ sender: Any) {
        
        guard recommendedProduct == false else { return }
        
        guard productCarousel.numberOfItems > 1, !productCarousel.isScrolling else { return }
        productCarousel.scrollToItem(at: productCarousel.currentItemIndex + 1, duration: 1.0)
    }
    
    @IBAction func reviewAction(_ sender: Any) {
        
        guard let reviewUrl = currentProduct["reviewUrl"] as? String,
            let productName = currentProduct["name"] as? String else { return }
        
        Analytics.logEvent(AnalyticsEvents.productReviewTapped, parameters: [
            AnalyticsParameterItemName: "product_name",
            AnalyticsParameterItemID: productName
            ])
 
        let webViewController = WebViewController()
        webViewController.urlString = reviewUrl
        self.present(webViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func purchaseAction(_ sender: Any) {
        
        let transactionID = "TX" + String(Int.random(in: 2000 ... 10000))
        
        guard let linkUrl = currentProduct["linkUrl"] as? String,
            let productName = currentProduct["name"] as? String,
            let url = LinkHelper.affiliateUrl(linkUrl, tracking: transactionID) else { return }
        
        Analytics.logEvent(AnalyticsEvents.productPurchaseTapped, parameters: [
            AnalyticsParameterItemName: "product_name",
            AnalyticsParameterItemID: productName,
            AnalyticsParameterTransactionID: transactionID
            ])
        
        if let price = currentProduct["price"] as? String,
            let priceNumber = Float(price.replacingOccurrences(of: "$", with: "")) {
            Analytics.logEvent(AnalyticsEventEcommercePurchase, parameters: [
                AnalyticsParameterValue: priceNumber,
                AnalyticsParameterCurrency: "USD",
                AnalyticsParameterTransactionID: transactionID
                ])
        }
        
        UIApplication.shared.open(url)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreInfoAction(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let configureVC = storyboard.instantiateViewController(withIdentifier: "MoreProductInfoViewController") as! MoreProductInfoViewController
        
        if let name = currentProduct["name"] as? String,
            let brand = currentProduct["brand"] as? String,
            let description = currentProduct["description"] as? String{
        
            configureVC.brandText = brand
            configureVC.nameText = name
            configureVC.descriptionText = description
        }
     
        let segue = ConfigureReminderSegue(identifier: nil, source: self, destination: configureVC)
            segue.perform()
    }
    
}

extension StoreViewController: iCarouselDelegate {
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == .wrap {
            return 1.0
        }
        if option == .tilt {
            return 0.6
        }
        if option == .fadeMax {
            return 0.3
        }
        if option == .fadeRange {
            return 0.5
        }
        
        return value
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        updateProductDisplay(animated: true)
    }
    
}

extension StoreViewController: iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return ProductService.shared.products.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        return productContentViewForIndex(carousel, viewForItemAt: index, reusing: view)
    }
    
    private func productContentViewForIndex(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let contentView = UIStackView(frame: carousel.bounds.insetBy(dx: 0, dy: 0))
        contentView.axis = .vertical
        contentView.backgroundColor = .clear
        let imageView = UIImageView(frame: contentView.bounds)
        imageView.contentMode = UIScreen.main.bounds.size.height < 700.0 ? .scaleAspectFit : .scaleAspectFill
        if let product = ProductService.shared.products[index] as? NSDictionary,
            let imageUrl = product["imageUrl"] as? String,
            let url = URL(string: imageUrl) {
            imageView.af_setImage(withURL: url)
        } else {
            imageView.image = UIImage(named: "temp-product")
        }
        
        contentView.addArrangedSubview(imageView)
        
        if let product = ProductService.shared.products[index] as? NSDictionary,
            let size = product["size"] as? String {
            let sizeLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: contentView.bounds.size.width, height: 44))
            sizeLabel.adjustsFontSizeToFitWidth = true
            sizeLabel.textAlignment = .center
            sizeLabel.textColor = .white
            sizeLabel.font = UIFont.systemFont(ofSize: 12.0)
            sizeLabel.text = "\(size) FL OZ"
            contentView.addArrangedSubview(sizeLabel)
        }
        
        return contentView
    }
    

}

extension StoreViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let ingredients = currentProduct["ingredients"] as? [String] {
            let name = ingredients[indexPath.row]
            return IngredientCollectionViewCell.sizeFor(name: name)
        }
        return CGSize.zero
    }
    
}

extension StoreViewController: UICollectionViewDelegate {
    
}

extension StoreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let ingredients = currentProduct["ingredients"] as? [String] else { return 0 }
        return ingredients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ingredient", for: indexPath)
        
        if let ingredientCell = cell as? IngredientCollectionViewCell,
            let ingredients = currentProduct["ingredients"] as? [String],
            let activeIngredients = currentProduct["activeIngredients"] as? [String] {
            let ingredient = ingredients[indexPath.row]
            let active = activeIngredients.contains(ingredient)
            ingredientCell.configure(name: ingredient, active: active)
        }
        
        return cell
    }
    
    
}
