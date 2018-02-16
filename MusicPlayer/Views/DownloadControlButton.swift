//
//  DownloadControlButton.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 08.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum DownloadControlState {
    
    case remove
    case reload
}

final class DownloadControlButton: UIButton {
    
    var controlState: DownloadControlState = .remove {
        didSet {
            setImage(controlState == .remove ? removeImage : reloadImage, for: .normal)
        }
    }
    
    private let removeImage = UIImage(named: "StopLoadIcon")
    private let reloadImage = UIImage(named: "ReloadIcon")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .center
        setImage(removeImage, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
