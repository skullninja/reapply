//
//  UserHelper.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 5/28/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation

class UserHelper: NSObject{
    
    static let shared = UserHelper()
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func setKeyInUserDefaults(key: String, value: String){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
   func hasCompletedOnboarding() -> Bool{
        return isKeyPresentInUserDefaults(key: "UserCompletedOnBoardingKey")
    }
    
    func setOnboardingComplete(){
        setKeyInUserDefaults(key: "UserCompletedOnBoardingKey", value: "true")
    }
    
    func seenLocationRequest() -> Bool{
        return isKeyPresentInUserDefaults(key: "UserSeenLocationRequestKey")
    }
    
    func setLocationRequestComplete(){
        setKeyInUserDefaults(key: "UserSeenLocationRequestKey", value: "true")
    }
    
    func seenNotificationRequest() -> Bool{
        return isKeyPresentInUserDefaults(key: "UserSeenNotificationRequestKey")
    }
    
    func setNotificationRequestComplete(){
        setKeyInUserDefaults(key: "UserSeenNotificationRequestKey", value: "true")
    }
    
    func hasTipNotificationsScheduled() -> Bool{
        return isKeyPresentInUserDefaults(key: "TipNotificationsRequestKey")
    }
    
    func setTipNotificationsScheduled(){
        setKeyInUserDefaults(key: "TipNotificationsRequestKey", value: "true")
    }
}
