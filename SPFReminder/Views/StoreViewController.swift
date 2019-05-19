//
//  StoreViewController.swift
//  SPFReminder
//
//  Created by Dave Peck on 5/8/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit
import iCarousel

class StoreViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnReview: UIButton!
    @IBOutlet weak var btnPurchase: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var carouselContainerView: UIView!
    
    let carousel = iCarousel(frame: .zero)
    
    let defaultHeaderImage = UIImage(named: "default")
    let timerHeaderImage = UIImage(named: "timer")
    let nightHeaderImage = UIImage(named: "night")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        btnPurchase.clipsToBounds = true
        btnPurchase.layer.cornerRadius = 8.0
        
        carouselContainerView.translatesAutoresizingMaskIntoConstraints = false
        carouselContainerView.addSubview(carousel)
        
        carousel.frame = carouselContainerView.bounds
        carousel.topAnchor.constraint(equalTo: carouselContainerView.topAnchor).isActive = true
        carousel.leftAnchor.constraint(equalTo: carouselContainerView.leftAnchor).isActive = true
        carousel.bottomAnchor.constraint(equalTo: carouselContainerView.bottomAnchor).isActive = true
        carousel.rightAnchor.constraint(equalTo: carouselContainerView.rightAnchor).isActive = true
        
        carousel.delegate = self
        carousel.dataSource = self
        carousel.isPagingEnabled = true
        carousel.type = .invertedTimeMachine
        carousel.reloadData()
    }
    
    @IBAction func previousProductAction(_ sender: Any) {
        guard carousel.numberOfItems > 1, !carousel.isScrolling else { return }
        carousel.scrollToItem(at: carousel.currentItemIndex - 1, duration: 1.0)
    }
    
    @IBAction func nextProductAction(_ sender: Any) {
        guard carousel.numberOfItems > 1, !carousel.isScrolling else { return }
        carousel.scrollToItem(at: carousel.currentItemIndex + 1, duration: 1.0)
    }
    
    @IBAction func reviewAction(_ sender: Any) {
        
    }
    
    @IBAction func purchaseAction(_ sender: Any) {
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
}

extension StoreViewController: iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 4
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let imageView = UIImageView(frame: carousel.bounds.insetBy(dx: 0, dy: 40))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "temp-product")
        return imageView
    }
    
}
