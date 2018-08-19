//
//  Fonts.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 06.08.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum Fonts {
    
    static let general = "Circe-Bold"
    
    static var libraryTitleFont: UIFont {
        return UIFont(name: Fonts.general, size: 30)!
    }
    
    static var libraryMenuCellFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        default : return UIFont(name: Fonts.general, size: 21)!
        }
    }

    static var librarySearchBarFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        default : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var songCellFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6, .iPhoneX : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var albumCellFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 18)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 19)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 20)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 19)!
        }
    }
    
    static var playlistCellFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 18)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 20)!
        }
    }
    
    static var albumMiniCellFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 19)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 20)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 20)!
        }
    }
    
    static var sortButtonFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var actionSheetFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 22)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 22)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 22)!
        }
    }
    
    static var clearTopBarFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var clearDownloadsButtonFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 19)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 20)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 20)!
        }
    }
    
    static var compilationViewTitleFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var albumViewArtistFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 19)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 20)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 20)!
        }
    }
    
    static var addMusicButtonFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 19)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 20)!
        }
    }
    
    static var settingCellFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var settingDescriptionViewFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 18)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 18)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 19)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 18)!
        }
    }
    
    static var songDownloadCellTitleFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var songDownloadCellProgressFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 17)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 18)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 18)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 18)!
        }
    }
    
    static var bookmarkCellFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var playerTitleFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 23)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 23)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 23)!
        }
    }
    
    static var playerArtistFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 19)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 21)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 21)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var playerProgressTimeFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 14)!
        case .iPhone6 : return UIFont(name: Fonts.general, size: 15)!
        case .iPhone6Plus : return UIFont(name: Fonts.general, size: 16)!
        case .iPhoneX : return UIFont(name: Fonts.general, size: 16)!
        }
    }
    
    static var playerBarFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        default : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var browserSearchFieldFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 20)!
        default : return UIFont(name: Fonts.general, size: 21)!
        }
    }
    
    static var browserCancelButtonFont: UIFont {
        switch currentDevice {
        case .iPhone5 : return UIFont(name: Fonts.general, size: 19)!
        default : return UIFont(name: Fonts.general, size: 20)!
        }
    }
    
}
