//
//  PlayerVolumeView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 30.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import MediaPlayer

final class PlayerVolumeView: VolumeView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        minTrackColor = UIColor(hex: "919191")
        maxTrackColor = UIColor(hex: "cecece")
        minValueImage = UIImage(named: "LessSoundIcon")
        maxValueImage = UIImage(named: "MoreSoundIcon")
        thumbImage = UIImage.roundImage(color: .white, diameter: 28, shadow: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VolumeView: MPVolumeView {
    
    private var slider: UISlider!
    
    private let minTrackView = UIView()
    
    private let maxTrackView = UIView()
    
    var minTrackColor = UIColor.blue {
        didSet {
            minTrackView.backgroundColor = minTrackColor
        }
    }
    
    var maxTrackColor = UIColor.lightGray {
        didSet {
            maxTrackView.backgroundColor = maxTrackColor
        }
    }
    
    var minValueImage: UIImage? {
        didSet {
            slider.minimumValueImage = minValueImage
        }
    }
    
    var maxValueImage: UIImage? {
        didSet {
            slider.maximumValueImage = maxValueImage
        }
    }
    
    var thumbImage: UIImage? {
        didSet {
            slider.setThumbImage(thumbImage, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        showsRouteButton = false
        
        slider = subviews.compactMap { $0 as? UISlider }.first!
        
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        
        slider.insertSubview(maxTrackView, at: 0)
        maxTrackView.backgroundColor = maxTrackColor
        maxTrackView.layer.cornerRadius = 1.6
        
        slider.insertSubview(minTrackView, aboveSubview: maxTrackView)
        minTrackView.backgroundColor = minTrackColor
        minTrackView.layer.cornerRadius = 1.6
        
        slider.addTarget(self, action: #selector(updateMinTrackView), for: .valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        
        maxTrackView.frame.size.height = 3
        maxTrackView.frame.size.width = trackRect.width
        maxTrackView.frame.origin.x = trackRect.minX
        maxTrackView.center.y = trackRect.midY
        
        minTrackView.frame.size.height = 3
        minTrackView.frame.origin.x = trackRect.minX
        minTrackView.center.y = trackRect.midY
        
        updateMinTrackView()
    }
    
    @objc private func updateMinTrackView() {
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
        minTrackView.frame.size.width = thumbRect.midX - minTrackView.frame.minX
    }
    
    override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.volumeSliderRect(forBounds: bounds)
        newRect.origin.y = (frame.height - newRect.height)/2
        return newRect
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
