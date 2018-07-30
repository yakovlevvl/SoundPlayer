//
//  BrowserDataManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 21.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import WebKit

final class BrowserDataManager {
    
    class func clearCookiesAndData() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.browserLastUrl)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
