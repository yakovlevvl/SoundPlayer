//
//  SettingsManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 20.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import Foundation

final class SettingsManager {
    
    static var spotlightIsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.enableSpotlight)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.enableSpotlight)
        }
    }
}
