//
//  PlayPauseButton.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 17.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum PlayPauseButtonState {
    
    case play
    case pause
}

final class PlayPauseButton: UIButton {
    
    var controlState: PlayPauseButtonState = .play {
        didSet {
            setImage(controlState == .play ? playImage : pauseImage, for: .normal)
        }
    }
    
    var playImage = UIImage(named: "PlayMiniIcon") {
        didSet {
            if controlState == .play {
                controlState = .play
            }
        }
    }
    
    var pauseImage = UIImage(named: "PauseMiniIcon") {
        didSet {
            if controlState == .pause {
                controlState = .pause
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .center
        setImage(playImage, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
