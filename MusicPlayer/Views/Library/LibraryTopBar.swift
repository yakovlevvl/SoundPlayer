//
//  LibraryTopBar.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 09.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class LibraryTopBar: UIView {
    
    weak var delegate: LibraryTopBarDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Library"
        label.frame.size = CGSize(width: 120, height: 34)
        label.font = Fonts.libraryTitleFont
        return label
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "SearchIcon"), for: .normal)
        button.contentMode = .center
        return button
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
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(searchButton)
        
        searchButton.addTarget(self, action: #selector(tapSearchButton), for: .touchUpInside)
    }
    
    private func layoutViews() {
        let y = frame.height/2
        
        titleLabel.center.y = y
        titleLabel.frame.origin.x = 30
        
        searchButton.center.y = y
        searchButton.frame.origin.x = frame.width - searchButton.frame.width - 24
    }
    
    @objc private func tapSearchButton() {
        delegate?.tapSearchButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol LibraryTopBarDelegate: class {
    
    func tapSearchButton()
}
