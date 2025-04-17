//
//  LinkHelper.swift
//  SPFReminder
//
//  Created by Dave Peck on 8/30/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation

class LinkHelper {
    
    private static let baseUrl = "https://go.skimresources.com?id=37750X1169153&xs=1&url="
    private static let baseTrackingParam = "&xcust="
    
    private static let trackingPrefixValue = "reapply"
    
    static func affiliateUrl(_ rawUrl: String, tracking: String?) -> URL? {
        if let escapedString = rawUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            print(escapedString)
            var url = baseUrl
            url += escapedString
            url += baseTrackingParam
            url += trackingPrefixValue
            if let tracking = tracking {
                url = url + "-" + tracking
            }
            return URL(string: url)
        }
        return nil
    }
}
