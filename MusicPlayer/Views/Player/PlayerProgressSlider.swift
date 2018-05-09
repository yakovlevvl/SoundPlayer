//
//  PlayerProgressSlider.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 21.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class PlayerProgressSlider: UISlider {
    
    private let thumbDiameter: CGFloat = 9
    
    private let thumbColor = UIColor(hex: "919191")
    
    private let selectedThumbColor = Colors.roundButtonColor
    
    private let minTrackColor = UIColor(hex: "919191")
    
    private let maxTrackColor = UIColor(hex: "cecece")
    
    private let thumbView = UIView()
    
    private let trackView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        maximumTrackTintColor = maxTrackColor
        minimumTrackTintColor = minTrackColor
        setThumbImage(UIImage.roundImage(color: thumbColor, diameter: thumbDiameter, shadow: false), for: .normal)
        
        thumbView.frame.size = CGSize(width: thumbDiameter, height: thumbDiameter)
        thumbView.layer.cornerRadius = thumbView.frame.height/2
        trackView.layer.cornerRadius = 1.6
        
        addTarget(self, action: #selector(touchBegan), for: .touchDown)
        addTarget(self, action: #selector(touchEnded), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc private func touchBegan() {
        let trackRect = self.trackRect(forBounds: bounds)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        
        addSubview(trackView)
        trackView.frame = trackRect
        trackView.backgroundColor = minTrackColor
        trackView.frame.size.width = thumbRect.midX - trackView.frame.minX
        
        addSubview(thumbView)
        thumbView.backgroundColor = thumbColor
        thumbView.center = CGPoint(x: thumbRect.midX, y: thumbRect.midY)
        
        UIView.animate(0.28) {
            self.thumbView.backgroundColor = self.selectedThumbColor
            self.trackView.backgroundColor = self.selectedThumbColor
            self.thumbView.transform = CGAffineTransform(scaleX: 3, y: 3)
        }
    }
    
    @objc private func touchEnded() {
        UIView.animate(0.28, animation: {
            self.thumbView.backgroundColor = self.thumbColor
            self.trackView.backgroundColor = self.minTrackColor
            self.thumbView.transform = .identity
        }, completion: { finished in
            if !finished { return }
            self.trackView.removeFromSuperview()
            self.thumbView.removeFromSuperview()
        })
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let thumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        thumbView.center = CGPoint(x: thumbRect.midX, y: thumbRect.midY)
        trackView.frame.size.width = thumbRect.midX - trackView.frame.minX
        return thumbRect
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 3
        return newBounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
