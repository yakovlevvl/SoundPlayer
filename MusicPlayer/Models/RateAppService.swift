//
//  RateAppService.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 28.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import StoreKit

final class RateAppService {
    
    class func incrementAppOpenedCount() {
        guard var appOpenCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.appOpenedCount) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.appOpenedCount)
            return
        }
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: UserDefaultsKeys.appOpenedCount)
    }
    
    class func checkAndAskForReview() {
        guard let appOpenCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.appOpenedCount) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.appOpenedCount)
            return
        }
        switch appOpenCount {
        case 10, 50 :
            self.requestReview()
        case _ where appOpenCount % 100 == 0 :
            self.requestReview()
        default : break
        }
    }
    
    private class func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    class func openAppStore() {
        let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/\(AppInfo.appId)?mt=8&action=write-review")!
        UIApplication.shared.open(appStoreURL, options: [:])
    }
}
