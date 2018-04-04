//
//  AlertView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 01.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class AlertView: UIView {
    
    var icon: UIImage? {
        get {
            return alertIcon.image
        }
        set {
            alertIcon.image = newValue
        }
    }
    
    var text: String {
        get {
            return alertLabel.attributedText!.string
        }
        set {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 8
            style.alignment = .center
            let attrString = NSAttributedString(string: newValue, attributes:
                [NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.font : font])
            alertLabel.attributedText = attrString
        }
    }
    
    var onTap: (() -> ())? {
        didSet {
            if onTap != nil {
                setupTapGesture()
            }
        }
    }
    
    var textColor = UIColor.black {
        didSet {
            alertLabel.textColor = textColor
        }
    }
    
    var textBackgroundColor = UIColor.clear {
        didSet {
            alertLabel.backgroundColor = textBackgroundColor
        }
    }
    
    var font = UIFont(name: Fonts.general, size: 21)!
    
    private let alertLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.frame.size = CGSize(width: 234, height: 60)
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        return label
    }()
    
    private let alertIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.frame.size = CGSize(width: 66, height: 66)
        imageView.contentMode = .center
        return imageView
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
        
        addSubview(alertIcon)
        addSubview(alertLabel)
    }
    
    private func layoutViews() {
        alertLabel.center.x = frame.width/2
        alertIcon.center.x = frame.width/2
        
        alertLabel.center.y = frame.height/2
        alertIcon.center.y = frame.height/2
        
        if icon != nil {
            alertIcon.center.y -= 40
            alertLabel.center.y += 40
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        alertIcon.addGestureRecognizer(tapGesture)
        alertLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapView() {
        onTap?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
