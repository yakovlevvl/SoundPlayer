//
//  ArtworkView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 14.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class ArtworkView: UIView {
    
    private let imageView: ImageView = {
        let imageView = ImageView()
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var showShadow = true {
        didSet {
            layer.shadowOpacity = showShadow ? 0.4 : 0
        }
    }
    
    var cornerRadius: CGFloat = 6 {
        didSet {
            imageView.layer.cornerRadius = cornerRadius
            layoutIfNeeded()
        }
    }
    
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
        imageView.layer.cornerRadius = cornerRadius
        addSubview(imageView)
        setupShadow()
    }
    
    private func layoutViews() {
        imageView.frame = bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
            cornerRadius: cornerRadius).cgPath
    }
    
    private func setupShadow() {
        layer.shadowOpacity = showShadow ? 0.4 : 0
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 14
    }
    
    func setArtwork(_ image: UIImage?) {
        if image == nil {
            setDefaultArtwork()
        } else {
            removeArtwork()
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    func setDefaultArtwork() {
        imageView.contentMode = .center
        if frame.width < 70 {
            imageView.image = UIImage(named: "AlbumMiniIcon")
        } else if frame.width > 70, frame.width < 180 {
            imageView.image = UIImage(named: "AlbumIcon")
        } else if frame.width > 180 {
            imageView.image = UIImage(named: "AlbumBigIcon")
        }
    }
    
    func showShadowAnimated() {
        let initialOpacity = layer.shadowOpacity
        layer.shadowOpacity = 0.4
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = initialOpacity
        animation.duration = 0.28
        layer.add(animation, forKey: nil)
    }
    
    func hideShadowAnimated() {
        let initialOpacity = layer.shadowOpacity
        layer.shadowOpacity = 0.2
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = initialOpacity
        animation.duration = 0.28
        layer.add(animation, forKey: nil)
    }
    
    func removeArtwork() {
        imageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
