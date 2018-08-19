//
//  Device.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 19.08.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum Device {
    
    case iPhone5
    case iPhone6
    case iPhone6Plus
    case iPhoneX
}

enum ScreenWidth {
    
    static let iPhone5: CGFloat = 320
    static let iPhone6: CGFloat = 375
    static let iPhone6Plus: CGFloat = 414
    static let iPhoneX: CGFloat = 375
}

enum ScreenHeight {
    
    static let iPhone5: CGFloat = 568
    static let iPhone6: CGFloat = 667
    static let iPhone6Plus: CGFloat = 736
    static let iPhoneX: CGFloat = 812
}

var currentDevice: Device {
    switch (screenWidth, screenHeight) {
    case (ScreenWidth.iPhone5, ScreenHeight.iPhone5) : return .iPhone5
    case (ScreenWidth.iPhone6, ScreenHeight.iPhone6) : return .iPhone6
    case (ScreenWidth.iPhoneX, ScreenHeight.iPhoneX) : return .iPhoneX
    case (ScreenWidth.iPhone6Plus, ScreenHeight.iPhone6Plus) : return .iPhone6Plus
    default : return .iPhoneX
    }
}
