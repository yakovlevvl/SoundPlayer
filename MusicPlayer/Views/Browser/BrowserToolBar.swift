//
//  BrowserToolBar.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BrowserToolBar: UIView  {
    
    weak var delegate: BrowserToolBarDelegate?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "PreviousIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "ForwardIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    private let bookmarksButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "BookmarkIcon"), for: .normal)
        button.tintColor = .black
        button.contentMode = .center
        return button
    }()
    
    private let downloadsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "DownloadsIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "CloseIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(backButton)
        addSubview(forwardButton)
        addSubview(bookmarksButton)
        addSubview(downloadsButton)
        addSubview(closeButton)
        
        backButton.addTarget(self, action: #selector(tapBackButton), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(tapForwardButton), for: .touchUpInside)
        bookmarksButton.addTarget(self, action: #selector(tapBookmarksButton), for: .touchUpInside)
        downloadsButton.addTarget(self, action: #selector(tapDownloadsButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let y = frame.height/2
        backButton.center.y = y
        forwardButton.center.y = y
        bookmarksButton.center.y = y
        downloadsButton.center.y = y
        closeButton.center.y = y
        
        let x = (frame.width/6).rounded()
        backButton.center.x = x - ( currentDevice == .iPhone5 ? 15 : 18 )
        forwardButton.center.x = 2*x - ( currentDevice == .iPhone5 ? 6 : 8 )
        bookmarksButton.center.x = 3*x
        downloadsButton.center.x = 4*x + 8
        closeButton.center.x = 5*x + 13
    }
    
    var isBackButtonEnabled: Bool {
        get { return backButton.isEnabled }
        set { backButton.isEnabled = newValue }
    }
    
    var isForwardButtonEnabled: Bool {
        get { return forwardButton.isEnabled }
        set { forwardButton.isEnabled = newValue }
    }
    
    @objc private func tapBackButton() {
        delegate?.tapBackButton()
    }
    
    @objc private func tapForwardButton() {
        delegate?.tapForwardButton()
    }
    
    @objc private func tapBookmarksButton() {
        delegate?.tapBookmarksButton()
    }
    
    @objc private func tapDownloadsButton() {
        delegate?.tapDownloadsButton()
    }
    
    @objc private func tapCloseButton() {
        delegate?.tapCloseButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol BrowserToolBarDelegate: class {
    
    func tapBackButton()
    func tapForwardButton()
    func tapBookmarksButton()
    func tapDownloadsButton()
    func tapCloseButton()
    
}
