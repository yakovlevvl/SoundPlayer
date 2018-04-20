//
//  MiniPlayerBar.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 16.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

protocol MiniPlayerBarDelegate: class {
    
    func tapPlayPauseButton()
    
    func tapNextButton()
    
    func tapPlayerBar()
}

final class MiniPlayerBar: UIView {
    
    weak var delegate: MiniPlayerBarDelegate?
    
    private let artworkView = ArtworkView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.frame.size.height = 28
        label.font = UIFont(name: Fonts.general, size: 20)
        return label
    }()
    
    private let playPauseButton: PlayPauseButton = {
        let button = PlayPauseButton(type: .custom)
        button.tintColor = .black
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "NextMiniIcon"), for: .normal)
        button.contentMode = .center
        return button
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
        backgroundColor = .white
        
        layer.borderWidth = 0.5
        layer.borderColor = Colors.gray.cgColor
        
        artworkView.cornerRadius = 3
        artworkView.showShadow = false
        
        addSubview(nextButton)
        addSubview(titleLabel)
        addSubview(artworkView)
        addSubview(playPauseButton)
        
        nextButton.addTarget(self, action: #selector(tapNextButton), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(tapPlayPauseButton), for: .touchUpInside)
        
        setupTapGesture()
    }
    
    private func layoutViews() {
        let artworkInset: CGFloat = 10
        let artworkHeight = frame.height - 2*artworkInset
        
        artworkView.frame.origin.x = 20
        artworkView.frame.size = CGSize(width: artworkHeight, height: artworkHeight)
        artworkView.center.y = frame.height/2
        
        playPauseButton.frame.size = CGSize(width: 46, height: artworkHeight)
        nextButton.frame.size = CGSize(width: 46, height: artworkHeight)
        
        playPauseButton.center.y = frame.height/2
        nextButton.center.y = frame.height/2
        
        nextButton.frame.origin.x = frame.width - nextButton.frame.width - 18
        playPauseButton.frame.origin.x = nextButton.frame.minX - playPauseButton.frame.width - 5
    
        titleLabel.frame.size.width = playPauseButton.frame.minX - titleLabel.frame.minX - 4
        titleLabel.center.y = frame.height/2
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPlayerBar))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapPlayPauseButton() {
        delegate?.tapPlayPauseButton()
    }
    
    @objc private func tapNextButton() {
        animateNextButton()
        delegate?.tapNextButton()
    }
    
    @objc private func tapPlayerBar() {
        delegate?.tapPlayerBar()
    }
    
    func showPlayButton() {
        setupPlayPauseButtonState(.play)
    }
    
    func showPauseButton() {
        setupPlayPauseButtonState(.pause)
    }
    
    private func setupPlayPauseButtonState(_ state: PlayPauseButtonState) {
        playPauseButton.layer.removeAllAnimations()
        UIView.animate(0.11, options: .allowUserInteraction, animation: {
            self.playPauseButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.playPauseButton.alpha = 0.3
        }, completion: { finished in
            if !finished { return }
            self.playPauseButton.controlState = state
            UIView.animate(0.11, options: .allowUserInteraction) {
                self.playPauseButton.transform = .identity
                self.playPauseButton.alpha = 1
            }
        })
    }
    
    private func animateNextButton() {
        nextButton.layer.removeAllAnimations()
        UIView.animate(0.11, options: .allowUserInteraction, animation: {
            self.nextButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.nextButton.alpha = 0.5
        }, completion: { finished in
            if !finished { return }
            UIView.animate(0.11, options: .allowUserInteraction) {
                self.nextButton.transform = .identity
                self.nextButton.alpha = 1
            }
        })
    }
    
    func setupTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setupArtwork(_ artwork: UIImage?) {
        artworkView.setArtwork(artwork)
        titleLabel.frame.origin.x = artworkView.frame.maxX + (artwork == nil ? 6 : 18)
        titleLabel.frame.size.width = playPauseButton.frame.minX - titleLabel.frame.minX - 4
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
