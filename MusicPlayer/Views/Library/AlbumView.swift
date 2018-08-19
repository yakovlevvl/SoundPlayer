//
//  AlbumView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 19.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class AlbumView: PlaylistView {
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 26
        label.textColor = Colors.red
        label.font = Fonts.albumViewArtistFont
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(artistLabel)
    }
    
    override func layoutViews() {
        super.layoutViews()
        artistLabel.frame.origin.y = titleLabel.frame.maxY + 5
        artistLabel.frame.origin.x = titleLabel.frame.origin.x
        artistLabel.frame.size.width = titleLabel.frame.width
    }
    
    func setupArtist(_ artist: String) {
        artistLabel.text = artist
    }
}

class PlaylistView: UICollectionReusableView {
    
    weak var delegate: PlaylistViewDelegate?
    
    private let artworkView: ArtworkView = {
        let view = ArtworkView()
        let height = UIProperties.CompilationView.artworkHeight
        view.frame.size = CGSize(width: height, height: height)
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 26
        label.font = Fonts.compilationViewTitleFont
        return label
    }()
    
    private let moreButton: RoundButton = {
        let button = RoundButton(type: .custom)
        let height = UIProperties.CompilationView.moreButtonHeight
        button.frame.size = CGSize(width: height, height: height)
        button.backgroundColor = Colors.roundButtonColor
        button.setImage(UIImage(named: "MoreIconWhite"))
        button.setShadowColor(Colors.red)
        button.setShadowOpacity(0.5)
        button.setShadowRadius(7)
        return button
    }()
    
    private let playButton: RoundButton = {
        let button = RoundButton(type: .custom)
        let height = UIProperties.CompilationView.playButtonHeight
        button.frame.size = CGSize(width: height, height: height)
        button.backgroundColor = Colors.roundButtonColor
        button.setImage(UIImage(named: "PlayMiniIcon"))
        button.imageEdgeInsets.left = 4
        button.setShadowColor(Colors.red)
        button.setShadowOpacity(0.5)
        button.setShadowRadius(10)
        button.tintColor = .white
        return button
    }()
    
    private let shuffleButton: RoundButton = {
        let button = RoundButton(type: .custom)
        let height = UIProperties.CompilationView.playButtonHeight
        button.frame.size = CGSize(width: height, height: height)
        button.backgroundColor = Colors.roundButtonColor
        button.setImage(UIImage(named: "ShuffleIcon"))
        button.setShadowColor(Colors.red)
        button.setShadowOpacity(0.5)
        button.setShadowRadius(10)
        button.tintColor = .white
        return button
    }()
    
    static let reuseId = "PlaylistView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        layoutViews()
    }
    
    fileprivate func setupViews() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(artworkView)
        
        addSubview(moreButton)
        addSubview(playButton)
        addSubview(shuffleButton)
        
        moreButton.addTarget(self, action: #selector(tapMoreButton), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(tapPlayButton), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(tapShuffleButton), for: .touchUpInside)
    }
    
    fileprivate func layoutViews() {
        artworkView.frame.origin = CGPoint(x: 20, y: UIProperties.CompilationView.artworkTopInset)
        
        titleLabel.frame.origin.y = artworkView.frame.minY + 8
        titleLabel.frame.origin.x = artworkView.frame.maxX + 20
        titleLabel.frame.size.width = frame.width - titleLabel.frame.minX - 20
        
        playButton.center.x = artworkView.center.x
        playButton.frame.origin.y = artworkView.frame.maxY + UIProperties.CompilationView.playButtonTopInset
        
        shuffleButton.frame.origin.x = playButton.frame.maxX + 32
        shuffleButton.center.y = playButton.center.y
        
        moreButton.frame.origin.x = frame.width - moreButton.frame.width - 28
        moreButton.frame.origin.y = artworkView.frame.maxY - moreButton.frame.height + 6
    }
    
    @objc private func tapMoreButton() {
        delegate?.tapMoreButton()
    }
    
    @objc private func tapPlayButton() {
        delegate?.tapPlayButton()
    }
    
    @objc private func tapShuffleButton() {
        delegate?.tapShuffleButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaylistView {
    
    func setupTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setupArtworkImage(_ image: UIImage?) {
        artworkView.setArtwork(image)
    }
}

protocol PlaylistViewDelegate: class {
    
    func tapMoreButton()
    func tapPlayButton()
    func tapShuffleButton()
}

protocol AlbumViewDelegate: PlaylistViewDelegate {}

