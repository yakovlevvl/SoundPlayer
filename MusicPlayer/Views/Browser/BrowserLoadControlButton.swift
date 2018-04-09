//
//  BrowserLoadControlButton.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 31.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum BrowserLoadControlState {

    case reload
    case stopLoad
}

final class BrowserLoadControlButton: UIButton {
    
    var controlState: BrowserLoadControlState = .reload {
        didSet {
            setImage(controlState == .reload ? reloadImage : stopImage, for: .normal)
        }
    }
    
    private let stopImage = UIImage(named: "StopLoadIcon")
    private let reloadImage = UIImage(named: "ReloadIcon")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .center
        setImage(reloadImage, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
