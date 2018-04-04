//
//  BrowserHistoryItemCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 04.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BrowserHistoryItemCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = UIFont(name: Fonts.general, size: 20)
        return label
    }()
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 30, height: 30)
        imageView.image = UIImage(named: "WebLinkIcon")
        imageView.contentMode = .center
        return imageView
    }()
    
    static let reuseId = "BrowserHistoryItemCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        
        layoutViews()
    }
    
    private func layoutViews() {
        icon.frame.origin.x = 22
        icon.center.y = contentView.center.y
        
        titleLabel.center.y = contentView.center.y
        titleLabel.frame.origin.x = icon.frame.maxX + 10
        
        titleLabel.frame.size.width = frame.width - titleLabel.frame.minX - 20
    }
    
    func setup(for item: BrowserHistoryItem) {
        titleLabel.text = item.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
