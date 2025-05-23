//
//  NewsCollectionViewCell.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/20/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit
import SDWebImage

class NewsCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView(cornerRadius: 8)
    
    let titleLabel = UILabel(text: "TITLE HERE", font: .systemFont(ofSize: 17, weight: .light))
    let sourceLabel = UILabel(text: "source", font: .systemFont(ofSize: 13, weight: .thin))
    
    let grayTextColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
    
    let imageSize:CGFloat = 90
    let padding:CGFloat = 30
    var isLoaded: Bool = false
    
    var news: News! {
           
        didSet {
            
            if let title = news.title{
                titleLabel.text = title
            }
               
            if let source =  news.source{
                sourceLabel.text = source
            }
            
            if let imageURL = news.imageUrl {
                if let url = URL(string: imageURL), UIApplication.shared.canOpenURL(url) {
                    // Valid URL - try to load remote image
                    imageView.sd_imageTransition = .fade
                    imageView.sd_setImage(with: url) { (_, _, _, _) in
                        self.isLoaded = true
                        for v in self.imageView.subviews {
                            v.removeFromSuperview()
                        }
                    }
                } else {
                    // Not a valid URL - try to load as system image
                    imageView.image = UIImage(systemName: imageURL)
                    self.isLoaded = true
                    for v in self.imageView.subviews {
                        v.removeFromSuperview()
                    }
                }
            }
            
       }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isLoaded = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // Removed imageView entirely

        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // Update width constraint to fit the full frame
        titleLabel.widthAnchor.constraint(equalToConstant: frame.width - 2 * padding).isActive = true

        sourceLabel.textColor = grayTextColor
        titleLabel.textColor = grayTextColor

        let verticalStack = VerticalStackView(arrangedSubviews: [sourceLabel, titleLabel], spacing: 4)

        // Now main stackView only has verticalStack
        let stackView = UIStackView(arrangedSubviews: [verticalStack])
        stackView.spacing = 15
        stackView.alignment = .leading  // or .fill if you want it to stretch

        addSubview(stackView)
        stackView.fillSuperview()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class VerticalStackView: UIStackView {

    init(arrangedSubviews: [UIView], spacing: CGFloat = 0) {
        super.init(frame: .zero)
        
        arrangedSubviews.forEach({addArrangedSubview($0)})
        
        self.spacing = spacing
        self.axis = .vertical
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
