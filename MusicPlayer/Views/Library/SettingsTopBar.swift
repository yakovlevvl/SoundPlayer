//
//  SettingsTopBar.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 14.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SettingsTopBar: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.frame.size = CGSize(width: 120, height: 34)
        label.font = Fonts.libraryTitleFont
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(titleLabel)
    }
    
    private func layoutViews() {
        titleLabel.center.y = frame.height/2
        titleLabel.frame.origin.x = 30
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
