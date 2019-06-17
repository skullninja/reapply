//
//  StoreAnimator.swift
//  SPFReminder
//
//  Created by Dave Peck on 5/16/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import UIKit

class StoreAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var type: StoreAnimatorType
    
    init(type: StoreAnimatorType) {
        self.type = type
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if let to = toVC, let from = fromVC,
            let transitionVC = storyboard.instantiateViewController(withIdentifier: "StoreTransitionViewController") as? StoreTransitionViewController {
            transitionVC.view.alpha = 0
            
            let containerView = transitionContext.containerView
            transitionVC.view.bounds = containerView.bounds
            containerView.addSubview(transitionVC.view)
            
            if self.type == .present {
                transitionVC.updateForMinValues()
            } else {
                transitionVC.updateForMaxValues()
            }
            
            let interval = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: interval / 8.0, animations: { () -> Void in
                transitionVC.view.alpha = 1.0
            }) { (completed) -> Void in
                if self.type == .dismiss {
                    from.view.alpha = 0
                    from.removeFromParent()
                    transitionVC.updateForMinValues()
                    UIView.animate(withDuration: interval / 1.33, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
                        transitionVC.view.layoutIfNeeded()
                    }, completion: { completed in
                        UIView.animate(withDuration: interval / 3.0, animations: {
                            transitionVC.view.alpha = 0.0
                        }, completion: { completed in
                            transitionVC.view.removeFromSuperview()
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                        })
                    })
                } else {
                    transitionVC.updateForMaxValues()
                    UIView.animate(withDuration: interval / 1.33, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
                        transitionVC.view.layoutIfNeeded()
                    }, completion: { completed in
                        to.view.frame = containerView.bounds
                        to.view.alpha = 0
                        containerView.addSubview(to.view)
                        to.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
                        to.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
                        to.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
                        to.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                        
                        UIView.animate(withDuration: interval / 8.0, animations: {
                            to.view.alpha = 1.0
                        }, completion: { completed in
                            transitionVC.view.removeFromSuperview()
                            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                        })
                    })
                }
                
                
            }
        } else {
            transitionContext.completeTransition(transitionContext.transitionWasCancelled)
        }
    }
        
}
