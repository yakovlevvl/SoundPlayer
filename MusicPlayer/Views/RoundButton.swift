//
//  RoundButton.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 25.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class RoundButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        contentMode = .center
        layer.shadowOffset = .zero
    }
    
    private func layoutViews() {
        layer.cornerRadius = frame.width/2
        layer.shadowPath = UIBezierPath(ovalIn: bounds).cgPath
    }
    
    func setImage(_ image: UIImage?) {
        setImage(image, for: .normal)
    }
    
    func setShadowOpacity(_ value: Float) {
        layer.shadowOpacity = value
    }
    
    func setShadowColor(_ color: UIColor) {
        layer.shadowColor = color.cgColor
    }
    
    func setShadowRadius(_ value: CGFloat) {
        layer.shadowRadius = value
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
