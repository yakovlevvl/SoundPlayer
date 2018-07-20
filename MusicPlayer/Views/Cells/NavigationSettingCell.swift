//
//  NavigationSettingCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 14.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class NavigationSettingCell: SettingCell {
    
    private let nextIcon: UIImageView = {
        let icon = UIImageView()
        icon.frame.size = CGSize(width: 30, height: 30)
        icon.image = UIImage(named: "NextSmall")
        icon.contentMode = .center
        return icon
    }()
    
    override class var reuseId: String {
        return "NavigationSettingCell"
    }
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(nextIcon)
    }
    
    override func layoutViews() {
        nextIcon.center.y = contentView.center.y
        nextIcon.frame.origin.x = contentView.frame.width - nextIcon.frame.width - 14
        
        titleLabel.center.y = contentView.center.y
        titleLabel.frame.origin.x = 30
        titleLabel.frame.size.width = nextIcon.frame.minX - titleLabel.frame.minX - 14
    }
}
