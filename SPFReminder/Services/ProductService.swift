//
//  ProductService.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 10/1/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation

class ProductService {
    
    static let shared = ProductService()
    
    var products: NSArray = {
        if let path = Bundle.main.path(forResource: "products", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            let rawArray = jsonResult as? NSArray ?? NSArray()
            var productArray = NSMutableArray()
            for product in rawArray {
                if var productDictionary = product as? [String: Any?],
                    let active = productDictionary["active"] as? String,
                    let inactive = productDictionary["inactive"] as? String {
                    let activeArray = active.components(separatedBy: ";")
                    let inactiveArray = inactive.components(separatedBy: ";")
                    productDictionary["activeIngredients"] = activeArray
                    productDictionary["inactiveIngredients"] = inactiveArray
                    productDictionary["ingredients"] = activeArray + inactiveArray
                    
                    if let imageUrl = productDictionary["imageUrl"] as? String,
                        let _ = URL(string: imageUrl) {
                        productArray.add(productDictionary)
                    }
                }
            }
            return productArray
        }
        return NSArray()
    }()
    
    func indexForProduct(_ product: Any) -> Int {
        let index = self.products.index(of: product)
        return index == NSNotFound ? 0 : index
    }
    
    func productForTags(_ tags: Array<String>) -> Any? {
        
        var foundProducts = [(sort: Int, product: Any)]()
        
        for product in products {
            if let productDictionary = product as? [String: Any?],
                let productTags = productDictionary["tags"] as? NSArray {
                
                var success = true
                for tag in tags {
                    if !productTags.contains(tag) {
                        success = false
                    }
                }
                
                if success {
                    foundProducts += [(sort: productTags.count, product: product)]
                }
            }
        }
        
        foundProducts.sort() { $0.sort < $1.sort }
        return foundProducts.count > 0 ? foundProducts[0].product : nil
    }
}


