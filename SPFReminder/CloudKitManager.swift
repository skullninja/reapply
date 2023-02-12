//
//  CloudKitManager.swift
//  SPFReminder
//
//  Created by Bart Jacobs on 13/10/2017.
//  Modified by Amber Reyngoudt on 03/7/2019
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import CloudKit

class CloudKitManager {
    
    static let shared = CloudKitManager()
    
    private let container = CKContainer.default()
    
    private var accountStatus: CKAccountStatus = .couldNotDetermine
    
    var hasAccount: Bool = false
    
    // MARK: - Notification Handling
    
    @objc private func accountDidChange(_ notification: Notification) {
        // Request Account Status
        DispatchQueue.main.async { self.requestAccountStatus(completionHandler: {}) }
    }
    
    // MARK: - Helper Methods
    
    func requestAccountStatus(completionHandler: @escaping () -> Void) {
        // Request Account Status
        container.accountStatus { [unowned self] (accountStatus, error) in
            // Print Errors
            if let error = error { print(error) }
            
            // Update Account Status
            switch accountStatus {
            case .available:
                print("available")
                self.accountStatus = CKAccountStatus.available
                self.hasAccount = true
            case .noAccount:
                print("no account")
                self.accountStatus = CKAccountStatus.noAccount
                self.hasAccount = false
            case .couldNotDetermine:
                if let e = error {
                    print("Error checking account status: \(e)")
                    self.accountStatus = CKAccountStatus.couldNotDetermine
                }
            case .restricted:
                print("restricted")
                self.accountStatus = CKAccountStatus.restricted
            default:
                print("default")
                // Do nothing (?)
            }
            
            
             completionHandler()
        }
        
        setupNotificationHandling()
       
    }
    
    // MARK: -
    
    fileprivate func setupNotificationHandling() {
        // Helpers
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(accountDidChange(_:)), name: Notification.Name.CKAccountChanged, object: nil)
    }
    
}
