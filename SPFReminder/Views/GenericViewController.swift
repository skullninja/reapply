//
//  GenericViewController.swift
//  SPFReminder
//
//  Created by Dave Peck on 5/18/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit

enum ScreenMode {
    case daytime
    case nightime
    case running
}

class GenericViewController: UIViewController {
    
    @IBOutlet weak var activeHeaderView: UIImageView!
    @IBOutlet weak var transitionHeaderView: UIImageView!
    
    @IBOutlet weak var btnStore: UIButton!
    
    var storeTransitioningDelegate: StoreTransitioningDelegate?
    var displayTimer: Timer!
    
    let defaultHeaderImage = UIImage(named: "default")
    let timerHeaderImage = UIImage(named: "timer")
    let nightHeaderImage = UIImage(named: "night")
    
    public var screenMode: ScreenMode = .daytime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayTimer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.updateDisplay), userInfo: nil, repeats: true)
        RunLoop.current.add(displayTimer, forMode: .common)
        updateDisplay()
    }
    
    @objc public func updateDisplay() {
        updateScreenMode()
    }
    
    func updateScreenMode() {
        if ReminderService.shared.isRunning {
            self.screenMode = .running
        } else if let uvIndex = ForecastService.shared.currentUVIndex,
            uvIndex < 1 {
            self.screenMode = .nightime
        } else {
            self.screenMode = .daytime
        }
        
        var activeHeaderImage = defaultHeaderImage
        switch self.screenMode {
        case .running:
            activeHeaderImage = timerHeaderImage
            break
        case .nightime:
            activeHeaderImage = nightHeaderImage
            break
        case .daytime:
            // Nothing
            break
        }
        
        if self.transitionHeaderView.image != activeHeaderImage {
            self.transitionHeaderView.image = activeHeaderImage
            UIView.animate(withDuration: 0.3, animations: {
                self.activeHeaderView.alpha = 0.0
            }) { _ in
                self.activeHeaderView.image = activeHeaderImage
                self.activeHeaderView.alpha = 1.0
            }
        }
    }
 
    @IBAction func storeAction(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let storeVC = storyboard.instantiateViewController(withIdentifier: "StoreViewController")
        self.storeTransitioningDelegate = StoreTransitioningDelegate(viewController: storeVC, presentingViewController: self)
        storeVC.modalPresentationStyle = .custom
        storeVC.transitioningDelegate = self.storeTransitioningDelegate
        present(storeVC, animated: true, completion: nil)
    }
}
