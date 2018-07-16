//
//  SettingCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 14.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SettingCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = UIFont(name: Fonts.general, size: 20)
        return label
    }()
    
    private let nextIcon: UIImageView = {
        let icon = UIImageView()
        icon.frame.size = CGSize(width: 30, height: 30)
        icon.image = UIImage(named: "NextSmall")
        icon.contentMode = .center
        return icon
    }()
    
    static let reuseId = "SettingCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(nextIcon)
        
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        setupShadow()
        
        layoutViews()
    }
    
    private func layoutViews() {
        nextIcon.center.y = contentView.center.y
        nextIcon.frame.origin.x = contentView.frame.width - nextIcon.frame.width - 14
        
        titleLabel.center.y = contentView.center.y
        titleLabel.frame.origin.x = 30
        titleLabel.frame.size.width = nextIcon.frame.minX - titleLabel.frame.minX - 14
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shadowOpacity = 0.09
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor(hex: "D0021B").cgColor
        layer.shadowRadius = 15
    }
    
    func setupTitle(_ title: String) {
        titleLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
