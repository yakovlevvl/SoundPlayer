//
//  SettingDescriptionView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 15.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SettingDescriptionView: UICollectionReusableView {
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = Fonts.settingDescriptionViewFont
        textView.textColor = .gray
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    static let reuseId = "SettingDescriptionView"
    
    static let textHorizontalInset: CGFloat = 24
    
    static let textVerticalInset: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        addSubview(textView)
        textView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    private func layoutViews() {
        textView.frame.size.height = frame.height - 2*SettingDescriptionView.textVerticalInset
        textView.frame.size.width = frame.width - 2*SettingDescriptionView.textHorizontalInset
        textView.center.x = frame.width/2
        textView.center.y = frame.height/2
    }
    
    func setupDescription(_ text: String) {
        textView.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
