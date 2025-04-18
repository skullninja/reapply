//
//  NewsService.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 4/21/20.
//  Copyright © 2020 Skull Ninja Inc. All rights reserved.
//

import Foundation
import Alamofire

@available(*, deprecated, message: "News Powered by Airtable.  No longer maintained or utilized.")
class NewsService{
    
    static let shared = NewsService() // Singleton
    
    fileprivate let key = "api_key=" + APIKeys.value(for: .airtableKey)
    fileprivate let app = APIKeys.value(for: .airtableApp)
    
    func fetchNews (completion: @escaping ([News]?, Error?) -> ()) {
        
        // Create a table named 'Articles' to host news stories.
        let urlString = "https://api.airtable.com/v0/\(app)/Articles?\(key)"
        
        //add some error handling
        AF.request(urlString).validate().response{ response in
            
            if ((response.error) != nil){
                print("Error with Airtable API. error:\(String(describing: response.error))")
                completion(nil, response.error)
            }
            
            let data: Data = response.data!
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            var newsArray : [News] = []
            if let dictionary = json as? [String: Any] {

                if dictionary["records"] != nil {
                    // access nested dictionary values by key
                    
                    if let array = dictionary["records"] as? [Any] {
               
                        for object in array {
                        // access all objects in array
                         
                            let newsObject = News()
                            let objectDic = object as? [String: Any]
                            newsObject.id = objectDic!["id"] as? String
                            
                            let fields = objectDic!["fields"] as? [String: Any]
                            newsObject.date = fields!["Date"] as? String
                            newsObject.title = fields!["Title"] as? String
                            newsObject.source = fields!["Source"] as? String
                            newsObject.url = fields!["Url"] as? String
                            newsObject.imageUrl = fields!["ImageUrl"] as? String
                            
                            newsArray.append(newsObject)
                        }
                    }
                }
            }
            
            completion(newsArray, nil)
        }
    }
}
 
