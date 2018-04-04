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
        button.setImage(UIImage(named: "BrowserIcon"), for: .normal)
        return button
    }()
    
    private let libraryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "LibraryIcon"), for: .normal)
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "SettingsIcon"), for: .normal)
        return button
    }()
    
    private lazy var buttons = [browserButton, libraryButton, settingsButton]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(browserButton)
        addSubview(libraryButton)
        addSubview(settingsButton)
        
        for button in buttons {
            button.tintColor = .black
            button.contentMode = .center
            button.frame.size = CGSize(width: 50, height: 50)
        }
        
        browserButton.addTarget(self, action: #selector(tapBrowserButton), for: .touchUpInside)
        libraryButton.addTarget(self, action: #selector(tapLibraryButton), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(tapSettingsButton), for: .touchUpInside)
        
        highlightButton(libraryButton)
    }
    
    private func layoutViews() {
        for button in buttons {
            button.center.y = frame.height/2
        }
        
        let value = frame.width/4
        
        browserButton.center.x = value - 24
        libraryButton.center.x = 2*value
        settingsButton.center.x = 3*value + 24
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
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
    
    private func highlightButton(_ selectedButton: UIButton) {
        for button in buttons {
            UIView.animate(0.18) {
                button.tintColor = button == selectedButton ? Colors.red : .black
            }
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
