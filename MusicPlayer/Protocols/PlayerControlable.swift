//
//  PlayerControlable.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

protocol PlayerControlable: class {
    
    var nextButton: UIButton { get }
    
    var previousButton: UIButton { get }
    
    var playPauseButton: PlayPauseButton { get }
}

extension PlayerControlable {
    
    var previousButton: UIButton {
        return UIButton()
    }
    
    func showPlayButton() {
        playPauseButton.controlState = .play
    }
    
    func showPauseButton() {
        playPauseButton.controlState = .pause
    }
    
    func decreasePlayPauseButton() {
        playPauseButton.imageView!.contentMode = .center
        UIView.animate(0.12) {
            self.playPauseButton.imageView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.playPauseButton.alpha = 0.3
        }
    }
    
    func increasePlayPauseButton() {
        UIView.animate(0.14) {
            self.playPauseButton.imageView!.transform = .identity
            self.playPauseButton.alpha = 1
        }
    }
    
    func animateNextButton() {
        animateControlButton(nextButton)
    }
    
    func animatePreviousButton() {
        animateControlButton(previousButton)
    }
    
    private func animateControlButton(_ button: UIButton) {
        button.layer.removeAllAnimations()
        button.imageView!.contentMode = .center
        UIView.animate(0.11, options: .allowUserInteraction, animation: {
            button.imageView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            button.alpha = 0.5
        }, completion: { finished in
            if !finished { return }
            UIView.animate(0.11, options: .allowUserInteraction) {
                button.imageView!.transform = .identity
                button.alpha = 1
            }
        })
    }
}


