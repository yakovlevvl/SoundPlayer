//
//  UIProperties.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 19.08.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum UIProperties {
    
    static let iPhoneXTopInset: CGFloat = 32
    
    static let playerBarHeight: CGFloat = 68
    
    static var songCellHeight: CGFloat {
        switch currentDevice {
        case .iPhone5 : return 70
        case .iPhone6 : return 72
        case .iPhone6Plus : return 72
        case .iPhoneX : return 72
        }
    }
    
    static var bookmarkCellHeight: CGFloat {
        switch currentDevice {
        case .iPhone5 : return 74
        case .iPhone6 : return 76
        case .iPhone6Plus : return 76
        case .iPhoneX : return 76
        }
    }
    
    static var actionSheetCellHeight: CGFloat {
        switch currentDevice {
        case .iPhone5 : return 68
        default : return 70
        }
    }
    
    static var alertControllerCellHeight: CGFloat {
        switch currentDevice {
        case .iPhone5 : return 58
        default : return 62
        }
    }
    
    enum CompilationView {
        
        static let artworkTopInset: CGFloat = 1
        
        static let playButtonTopInset: CGFloat = 30
        
        static let playButtonBottomInset: CGFloat = 31
        
        static var artworkHeight: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 110
            case .iPhone6 : return 140
            case .iPhone6Plus : return 160
            case .iPhoneX : return 140
            }
        }
        
        static var playButtonHeight: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 54
            case .iPhone6 : return 56
            case .iPhone6Plus : return 56
            case .iPhoneX : return 56
            }
        }
        
        static var moreButtonHeight: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 34
            case .iPhone6 : return 36
            case .iPhone6Plus : return 36
            case .iPhoneX : return 36
            }
        }
        
        static var height: CGFloat {
            return self.artworkHeight + self.artworkTopInset +
                self.playButtonTopInset + self.playButtonHeight +
                self.playButtonBottomInset
        }
    }
    
    enum AlbumCell {
        
        static var titleTopInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 10
            case .iPhone6 : return 12
            case .iPhone6Plus : return 12
            case .iPhoneX : return 12
            }
        }
        
        static var artistHeight: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 22
            case .iPhone6 : return 25
            case .iPhone6Plus : return 25
            case .iPhoneX : return 25
            }
        }
        
        static var descriptionHeight: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 54
            case .iPhone6 : return 60
            case .iPhone6Plus : return 60
            case .iPhoneX : return 60
            }
        }
    }
    
    enum PlaylistCell {
        
        static var titleTopInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 14
            case .iPhone6 : return 16
            case .iPhone6Plus : return 16
            case .iPhoneX : return 16
            }
        }
        
        static var descriptionHeight: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 40
            case .iPhone6 : return 44
            case .iPhone6Plus : return 44
            case .iPhoneX : return 44
            }
        }
    }
    
    enum Player {
        
        static var artworkWidth: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 240
            case .iPhone6 : return 295
            case .iPhone6Plus : return 334
            case .iPhoneX : return 325
            }
        }
        
        static var closeButtonTopInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 12
            case .iPhone6 : return 16
            case .iPhone6Plus : return 18
            case .iPhoneX : return 50
            }
        }
        
        static var closeButtonBottomInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 12
            case .iPhone6 : return 16
            case .iPhone6Plus : return 18
            case .iPhoneX : return 20
            }
        }
        
        static var progressViewTopInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 4
            case .iPhone6 : return 10
            case .iPhone6Plus : return 12
            case .iPhoneX : return 18
            }
        }
        
        static var progressViewBottomInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 4
            case .iPhone6 : return 10
            case .iPhone6Plus : return 12
            case .iPhoneX : return 18
            }
        }
        
        static var titleBottomInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 1
            case .iPhone6 : return 5
            case .iPhone6Plus : return 6
            case .iPhoneX : return 5
            }
        }
        
        static var artistBottomInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 13
            case .iPhone6 : return 20
            case .iPhone6Plus : return 23
            case .iPhoneX : return 32
            }
        }
        
        static var playButtonBottomInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 9
            case .iPhone6 : return 17
            case .iPhone6Plus : return 20
            case .iPhoneX : return 32
            }
        }
        
        static var volumeBottomInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 8
            case .iPhone6 : return 10
            case .iPhone6Plus : return 17
            case .iPhoneX : return 26
            }
        }
        
        static var progressTimeTopInset: CGFloat {
            switch currentDevice {
            case .iPhone5 : return 2
            case .iPhone6 : return 3
            case .iPhone6Plus : return 5
            case .iPhoneX : return 5
            }
        }
    }
}
