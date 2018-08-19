//
//  BookmarkCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 02.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BookmarkCell: UICollectionViewCell {
    
    weak var delegate: BookmarkCellDelegate?
    
    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 30, height: 30)
        imageView.image = UIImage(named: "BookmarkIcon")
        imageView.contentMode = .center
        imageView.tintColor = UIColor(hex: "4A90E2")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = Fonts.bookmarkCellFont
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 42, height: 58)
        button.setImage(UIImage(named: "MoreIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    static let reuseId = "BookmarkCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(moreButton)
        
        moreButton.addTarget(self, action: #selector(tapMoreButton), for: .touchUpInside)
        
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        setupShadow()
        
        layoutViews()
    }
    
    private func layoutViews() {
        icon.center.y = contentView.center.y
        titleLabel.center.y = contentView.center.y
        moreButton.center.y = contentView.center.y
        
        icon.frame.origin.x = 16
        moreButton.frame.origin.x = frame.width - moreButton.frame.width - 3
        
        titleLabel.frame.origin.x = icon.frame.maxX + 12
        
        titleLabel.frame.size.width = moreButton.frame.minX - titleLabel.frame.minX + 2
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shadowOpacity = 0.12
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 7
    }
    
    @objc private func tapMoreButton() {
        delegate?.tapMoreButton(self)
    }
    
    func setup(for bookmark: Bookmark) {
        titleLabel.text = bookmark.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol BookmarkCellDelegate: class {
    
    func tapMoreButton(_ cell: BookmarkCell)
}
