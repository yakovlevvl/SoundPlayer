//
//  TabBar.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 24.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class TabBar: UIView {
    
    weak var delegate: TabBarDelegate?
    
    private let browserButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "BrowserIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    private let libraryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "LibraryIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "SettingsIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(browserButton)
        addSubview(libraryButton)
        addSubview(settingsButton)
        
        browserButton.addTarget(self, action: #selector(tapBrowserButton), for: .touchUpInside)
        libraryButton.addTarget(self, action: #selector(tapLibraryButton), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(tapSettingsButton), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        browserButton.center.y = frame.height/2
        libraryButton.center.y = frame.height/2
        settingsButton.center.y = frame.height/2
        
        browserButton.center.x = frame.width/4
        libraryButton.center.x = 2*frame.width/4
        settingsButton.center.x = 3*frame.width/4
    }
    
    @objc private func tapBrowserButton() {
        delegate?.tapBrowserButton()
    }
    
    @objc private func tapLibraryButton() {
        highlightButton(libraryButton)
        delegate?.tapLibraryButton()
    }
    
    @objc private func tapSettingsButton() {
        highlightButton(settingsButton)
        delegate?.tapSettingsButton()
    }
    
    private func highlightButton(_ button: UIButton) {
        button.tintColor = UIColor(hex: "D0021B")
        if button.isEqual(libraryButton) {
            settingsButton.tintColor = .black
        } else {
            libraryButton.tintColor = .black
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol TabBarDelegate: class {
    
    func tapBrowserButton()
    func tapLibraryButton()
    func tapSettingsButton()
    
}
