//
//  SettingCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 18.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class SettingCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = Fonts.settingCellFont
        return label
    }()
    
    class var reuseId: String {
        return "SettingCell"
    }
    
    var scaleByTap = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }
    
    func setupViews() {
        contentView.addSubview(titleLabel)
        
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        setupShadow()
    }
    
    func layoutViews() {
        titleLabel.center.y = contentView.center.y
        titleLabel.frame.origin.x = 30
        titleLabel.frame.size.width = frame.width - titleLabel.frame.minX - 20
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
    
    func setupTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    override var isHighlighted: Bool {
        didSet {
            if !scaleByTap { return }
            if isHighlighted {
                UIView.animate(0.2) {
                    self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                    self.contentView.backgroundColor = UIColor(white: 1, alpha: 0.6)
                }
            } else {
                UIView.animate(0.4) {
                    self.transform = .identity
                    self.contentView.backgroundColor = .white
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
