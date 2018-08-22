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
    
    func animatePlayPauseButton() {
        playPauseButton.imageView!.contentMode = .center
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1
        scaleAnim.toValue = 0.6
        scaleAnim.duration = 0.10
        scaleAnim.autoreverses = true
        scaleAnim.fillMode = kCAFillModeForwards
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = 1
        fadeAnim.toValue = 0.24
        fadeAnim.duration = 0.12
        fadeAnim.autoreverses = true
        fadeAnim.fillMode = kCAFillModeForwards
        
        playPauseButton.imageView!.layer.add(scaleAnim, forKey: nil)
        playPauseButton.imageView!.layer.add(fadeAnim, forKey: nil)
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


