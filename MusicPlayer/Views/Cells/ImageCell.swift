//
//  ImageCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 27.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        return imageView
    }()
    
    static let reuseId = "ImageCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        contentView.backgroundColor = Colors.darkWhite
        contentView.addSubview(imageView)
        layoutViews()
    }
    
    private func layoutViews() {
        imageView.frame = bounds
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
