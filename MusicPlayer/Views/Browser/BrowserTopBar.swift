//
//  BrowserTopBar.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 24.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BrowserTopBar: UIView {
    
    weak var delegate: BrowserTopBarDelegate?
    
    private let searchField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search music"
        textField.keyboardType = .webSearch
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .go
        textField.font = UIFont(name: Fonts.general, size: Screen.is4inch ? 20 : 21)
        textField.frame.size.height = 46
        textField.borderStyle = .none
        return textField
    }()
    
    private let searchIcon: UIImageView = {
        let icon = UIImageView()
        icon.frame.size = CGSize(width: 30, height: 30)
        icon.image = UIImage(named: "BrowserSearchIcon")
        icon.contentMode = .center
        return icon
    }()
    
    private let loadControlButton: BrowserLoadControlButton = {
        let button = BrowserLoadControlButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 70, height: 50)
        button.titleLabel!.font = UIFont(name: Fonts.general, size: Screen.is4inch ? 19 : 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    
    var keyboardIsShown = false
    
    override var frame: CGRect {
        didSet {
            guard frame.size != oldValue.size else { return }
            layoutViews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(searchIcon)
        addSubview(searchField)
        addSubview(cancelButton)
        addSubview(loadControlButton)
        
        cancelButton.alpha = 0
        loadControlButton.alpha = 0
        
        searchField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        loadControlButton.addTarget(self, action: #selector(tapLoadControlButton), for: .touchUpInside)
    }
    
    private func layoutViews() {
        let y = frame.height/2
        searchIcon.center.y = y - 1
        searchField.center.y = y
        loadControlButton.center.y = y
        cancelButton.center.y = y
        
        searchIcon.frame.origin.x = 18
        searchField.frame.origin.x = searchIcon.frame.maxX + 14
        
        loadControlButton.frame.origin.x = frame.width - loadControlButton.frame.width - 8
        cancelButton.frame.origin.x = frame.width - cancelButton.frame.width - 13
    
        searchField.frame.size.width = loadControlButton.frame.minX - searchField.frame.minX - 6
    }
    
    func hideLoadControlButton() {
        loadControlButton.alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BrowserTopBar {
    
    var searchFieldText: String {
        get { return searchField.text! }
        set { searchField.text = newValue }
    }
    
    @objc private func tapLoadControlButton() {
        switch loadControlButton.controlState {
            case .reload : delegate?.tapReloadButton()
            case .stopLoad : delegate?.tapStopButton()
        }
    }
    
    @objc private func tapCancelButton() {
        hideKeyboard()
        delegate?.cancelSearchFieldEditing()
    }
    
    func showReloadButton() {
        showLoadControlButton(with: .reload)
    }
    
    func showStopButton() {
        showLoadControlButton(with: .stopLoad)
    }
    
    private func showLoadControlButton(with state: BrowserLoadControlState) {
        loadControlButton.layer.removeAllAnimations()
        UIView.animate(0.18, damping: 0.95, velocity: 0.8, animation: {
            self.loadControlButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.loadControlButton.alpha = 0
        }, completion: { finished in
            if !finished { return }
            self.loadControlButton.controlState = state
            if self.keyboardIsShown { return }
            UIView.animate(0.3, damping: 0.95, velocity: 0.8, options: .allowUserInteraction) {
                self.loadControlButton.transform = .identity
                self.loadControlButton.alpha = 1
            }
        })
    }
    
    private func showKeyboard() {
        keyboardIsShown = true
        cancelButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(0.35, damping: 0.95, velocity: 0.8) {
            self.searchIcon.transform = CGAffineTransform(translationX: -50, y: 0)
            self.loadControlButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.loadControlButton.alpha = 0
            self.cancelButton.transform = .identity
            self.cancelButton.alpha = 1
            self.searchField.frame.origin.x = 22
            self.searchField.frame.size.width = self.cancelButton.frame.minX - self.searchField.frame.minX - 6
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(0.4, damping: 0.8, velocity: 0.8) {
                self.searchField.becomeFirstResponder()
            }
        }
    }
    
    func hideKeyboard() {
        keyboardIsShown = false
        UIView.animate(0.2, options: .curveEaseOut) {
            self.searchField.resignFirstResponder()
        }
        UIView.animate(0.35, damping: 0.95, velocity: 0.8) {
            self.cancelButton.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.cancelButton.alpha = 0
            self.loadControlButton.transform = .identity
            if self.delegate!.shouldShowLoadControlButton() {
                self.loadControlButton.alpha = 1
            }
            self.searchIcon.transform = .identity
            self.searchField.frame.origin.x = self.searchIcon.frame.maxX + 14
            self.searchField.frame.size.width = self.loadControlButton.frame.minX - self.searchField.frame.minX - 6
        }
    }
}

extension BrowserTopBar: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let delegate = delegate else { return true }
        return delegate.searchFieldShouldReturn(with: textField.text ?? "")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard !keyboardIsShown else { return true }
        showKeyboard()
        if let delegate = delegate {
            delegate.searchFieldDidBeginEditing()
        }
        return false
    }
}

protocol BrowserTopBarDelegate: class {
    
    func tapStopButton()
    func tapReloadButton()
    func cancelSearchFieldEditing()
    func searchFieldShouldReturn(with text: String) -> Bool
    func shouldShowLoadControlButton() -> Bool
    func searchFieldDidBeginEditing()
    
}

