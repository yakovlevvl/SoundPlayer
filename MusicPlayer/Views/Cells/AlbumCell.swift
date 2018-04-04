//
//  AlbumCell.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 12.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class PlaylistCell: UICollectionViewCell {
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 22
        label.font = UIFont(name: Fonts.general, size: 17)
        return label
    }()
    
    private let artworkView = ArtworkView()
    
    static let reuseId = "PlaylistCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }
    
    fileprivate func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(artworkView)
    }
    
    fileprivate func layoutViews() {
        artworkView.frame.origin = .zero
        artworkView.frame.size = CGSize(width: frame.width, height: frame.width)
        
        titleLabel.frame.origin.x = 3
        titleLabel.frame.origin.y = artworkView.frame.maxY + 10
        titleLabel.frame.size.width = frame.width
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setArtwork(_ artwork: UIImage?) {
        artworkView.setArtwork(artwork)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.removeArtwork()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class AlbumCell: PlaylistCell {
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 22
        label.font = UIFont(name: Fonts.general, size: 17)
        label.textColor = UIColor(hex: "9B9B9B")
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(artistLabel)
    }
    
    override func layoutViews() {
        super.layoutViews()
        artistLabel.frame.origin.x = 3
        artistLabel.frame.origin.y = titleLabel.frame.maxY
        artistLabel.frame.size.width = frame.width
    }
    
    func setArtist(_ artist: String) {
        artistLabel.text = artist
    }
}

final class AlbumCell2: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 22
        label.font = UIFont(name: Fonts.general, size: 17)
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 22
        label.font = UIFont(name: Fonts.general, size: 17)
        label.textColor = UIColor(hex: "9B9B9B")
        return label
    }()
    
    private let artworkView = ArtworkView()
    
    static let reuseId = "AlbumCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(artworkView)
        
        layoutViews()
    }
    
    private func layoutViews() {
        artworkView.frame.origin = .zero
        artworkView.frame.size = CGSize(width: frame.width, height: frame.width)
        
        titleLabel.frame.origin.x = 3
        titleLabel.frame.origin.y = artworkView.frame.maxY + 10
        titleLabel.frame.size.width = frame.width
        
        artistLabel.frame.origin.x = 3
        artistLabel.frame.origin.y = titleLabel.frame.maxY
        artistLabel.frame.size.width = frame.width
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setArtist(_ artist: String) {
        artistLabel.text = artist
    }
    
    func setArtwork(_ artwork: UIImage?) {
        artworkView.setArtwork(artwork)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.removeArtwork()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
