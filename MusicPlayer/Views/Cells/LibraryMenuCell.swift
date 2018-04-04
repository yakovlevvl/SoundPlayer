//
//  LibraryMenuCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 09.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class LibraryMenuItemCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.frame.size.height = 28
        label.font = UIFont(name: Fonts.general, size: 20)
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected == oldValue { return }
            UIView.transition(with: titleLabel, duration: 0.25, options: .transitionCrossDissolve,
                animations: {
                self.titleLabel.textColor = self.isSelected ? UIColor(hex: "D0021B") : .black
            })
        }
    }
    
    static let reuseId = "LibraryMenuItemCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        
        layoutViews()
    }
    
    private func layoutViews() {
        titleLabel.frame = contentView.frame
    }
    
    func setup(for item: LibraryItems) {
        titleLabel.text = item.rawValue
    }
    
    func setupTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
