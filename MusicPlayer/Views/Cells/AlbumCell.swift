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
        label.font = Fonts.playlistCellFont
        return label
    }()
    
    fileprivate let artworkView = ArtworkView()
    
    class var reuseId: String {
        return "PlaylistCell"
    }
    
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
        titleLabel.frame.origin.y = artworkView.frame.maxY + UIProperties.PlaylistCell.titleTopInset
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

class AlbumCell: PlaylistCell {
    
    fileprivate let artistLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = UIProperties.AlbumCell.artistHeight
        label.font = Fonts.albumCellFont
        label.textColor = UIColor(hex: "9B9B9B")
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        contentView.addSubview(artistLabel)
        titleLabel.font = Fonts.albumCellFont
    }
    
    override func layoutViews() {
        super.layoutViews()
        artistLabel.frame.origin.x = 3
        titleLabel.frame.origin.y = artworkView.frame.maxY + UIProperties.AlbumCell.titleTopInset
        artistLabel.frame.origin.y = titleLabel.frame.maxY
        artistLabel.frame.size.width = frame.width
    }
    
    func setArtist(_ artist: String) {
        artistLabel.text = artist
    }
}

final class AlbumMiniCell: AlbumCell {
    
    override class var reuseId: String {
        return "AlbumMiniCell"
    }
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        artworkView.showShadow = false
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        titleLabel.font = Fonts.albumMiniCellFont
        artistLabel.font = Fonts.albumMiniCellFont
        
        setupShadow()
    }
    
    override func layoutViews() {
        let artworkInset: CGFloat = 12
        let artworkHeight = frame.height - 2*artworkInset
        artworkView.frame.origin.x = artworkInset
        artworkView.frame.size = CGSize(width: artworkHeight, height: artworkHeight)
        artworkView.center.y = frame.height/2
        
        titleLabel.frame.origin.x = artworkView.frame.maxX + 16
        titleLabel.frame.size.width = frame.width - titleLabel.frame.minX - 10
        titleLabel.center.y = frame.height/2 - 14
        
        artistLabel.frame.origin.x = titleLabel.frame.origin.x
        artistLabel.frame.size.width = titleLabel.frame.width
        artistLabel.center.y = frame.height/2 + 14
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shadowOpacity = 0.08  //0.12 0.08
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor(hex: "D0021B").cgColor //UIColor.gray.cgColor
        layer.shadowRadius = 15
    }
}

final class PlaylistMiniCell: PlaylistCell {
    
    override class var reuseId: String {
        return "PlaylistMiniCell"
    }
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .clear
        contentView.backgroundColor = .white
        
        artworkView.showShadow = false
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        titleLabel.font = Fonts.songCellFont
        
        setupShadow()
    }
    
    override func layoutViews() {
        let artworkInset: CGFloat = 12
        let artworkHeight = frame.height - 2*artworkInset
        artworkView.frame.origin.x = artworkInset
        artworkView.frame.size = CGSize(width: artworkHeight, height: artworkHeight)
        artworkView.center.y = frame.height/2
        
        titleLabel.frame.origin.x = artworkView.frame.maxX + 16
        titleLabel.frame.size.width = frame.width - titleLabel.frame.minX - 10
        titleLabel.center.y = frame.height/2
    }
    
    private func setupShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.shadowOpacity = 0.08  //0.12 0.08
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor(hex: "D0021B").cgColor //UIColor.gray.cgColor
        layer.shadowRadius = 15
    }
}

