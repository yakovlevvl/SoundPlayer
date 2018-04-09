//
//  SearchTitleHeader.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 07.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SearchTitleHeader: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = UIFont(name: Fonts.general, size: 23)
        return label
    }()
    
    static let reuseId = "SearchTitleHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        backgroundColor = .clear
    }
    
    private func layoutViews() {
        titleLabel.frame.origin.x = 30
        titleLabel.center.y = frame.height/2
        titleLabel.frame.size.width = frame.width - titleLabel.frame.minX
    }
    
    func setupTitle(_ title: String) {
        titleLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
