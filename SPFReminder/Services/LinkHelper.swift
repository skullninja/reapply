//
//  LinkHelper.swift
//  SPFReminder
//
//  Created by Dave Peck on 8/30/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation

class LinkHelper {
    
    private static let baseUrl = APIKeys.value(for: .affiliateLinkBaseURL)
    private static let baseTrackingParam = APIKeys.value(for: .affiliateLinkBaseTrackingParam)
    private static let trackingPrefixValue = APIKeys.value(for: .affiliateLinkBaseTrackingValue)
    
    static func affiliateUrl(_ rawUrl: String, tracking: String?) -> URL? {
        // If baseUrl is empty, return rawUrl directly
        if baseUrl.isEmpty {
            return URL(string: rawUrl)
        }

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
