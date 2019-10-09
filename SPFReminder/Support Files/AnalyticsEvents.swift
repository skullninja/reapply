//
//  AnalyticsEvents.swift
//  SPFReminder
//
//  Created by Dave Peck on 7/16/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import Foundation

struct AnalyticsEvents {
    static let storeTapped = "store_tapped"
    static let stopTapped = "stop_tapped"
    static let applyTapped = "apply_tapped"
    static let reapplyTapped = "reapply_tapped"
    static let timerStarted = "timer_started"
    static let suncareTapped = "suncare_tapped"
    static let safetyTipsTapped = "safety_tips_tapped"
    static let reviewsTapped = "reviews_tapped"
    static let shopFavesTapped = "shop_faves_tapped"
    static let productReviewTapped = "product_review_tapped"
    static let productPurchaseTapped = "product_purchased_tapped"
    
    static let quizTapped = "quiz_tapped"
    static let quizQuestionAnswered = "quiz_question_answered"
    static let quizRecommendedProduct = "quiz_recommended_product"
    
    static let notificationReapplyTapped = "notification_reapply_tapped"
    static let notificationStopTapped = "notification_stop_tapped"
    static let notificationTapped = "notification_tapped"
}
