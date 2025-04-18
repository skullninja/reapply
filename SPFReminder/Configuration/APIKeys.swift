//
//  APIKeys.swift
//  SPFReminder
//
//  Created by Dave Peck on 4/16/25.
//  Copyright © 2025 Skull Ninja Inc. All rights reserved.
//

import Foundation

enum APIKeys {
    private static var values: [String: String] = {
        guard let url = Bundle.main.url(forResource: "APIKeys", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] else {
            #if DEBUG
            print("⚠️ Could not load APIKeys.plist or cast to [String: String]")
            #endif
            return [:]
        }
        return dict
    }()

    static func value(for key: String) -> String {
        return values[key] ?? ""
    }
}

extension APIKeys {
    enum Key: String {
        case affiliateLinkBaseURL
        case affiliateLinkBaseTrackingParam
        case affiliateLinkBaseTrackingValue
        case airtableKey
        case airtableApp
        case sunCareBasicsURL
        case safetyTipsURL
        case reviewsURL
        case spfURL
        case uvIndexURL
        case chemicalURL
        case raysURL
    }

    static func value(for key: Key) -> String {
        return value(for: key.rawValue)
    }
}
