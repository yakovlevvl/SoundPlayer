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
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    var showShadow = true
    
    var cornerRadius: CGFloat = 6
    
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
        addSubview(imageView)
    }
    
    private func layoutViews() {
        imageView.frame = bounds
        imageView.layer.cornerRadius = cornerRadius
        if showShadow {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds,
            cornerRadius: 6).cgPath
        layer.shadowOpacity = 0.4
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 14
    }
    
    func setArtwork(_ image: UIImage?) {
        if image == nil {
            setDefaultArtwork()
        } else {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    func setDefaultArtwork() {
        imageView.contentMode = .center
        imageView.image = UIImage(named: frame.width > 70 ? "AlbumIcon" : "AlbumMiniIcon")
    }
    
    func removeArtwork() {
        imageView.image = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
