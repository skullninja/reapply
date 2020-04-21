//
//  NewsCollectionViewCell.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/20/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import UIKit

class NewsCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView(cornerRadius: 8)
    
    let titleLabel = UILabel(text: "TITLE HERE", font: .systemFont(ofSize: 18))
    let sourceLabel = UILabel(text: "source", font: .systemFont(ofSize: 14))
    
    var news: News! {
           
        didSet {
            
            if let title = news.title{
                titleLabel.text = title
            }
               
            if let source =  news.source{
                sourceLabel.text = source
            }
       }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.backgroundColor = .orange
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        self.titleLabel.numberOfLines = 3
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.titleLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        
        let stackView = UIStackView(arrangedSubviews: [VerticalStackView(arrangedSubviews: [sourceLabel, titleLabel], spacing: 4), imageView])
        stackView.spacing = 15
        
        stackView.alignment = .center
        
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
