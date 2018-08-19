//
//  PlayerProgressView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 07.05.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

protocol PlayerProgressViewDelegate: class {
    
    func sliderBeganDrag()
    
    func sliderEndedDrag()
    
    func sliderIsDragging()
}

final class PlayerProgressView: UIView {
    
    weak var delegate: PlayerProgressViewDelegate?
    
    private let slider = PlayerProgressSlider()
    
    private let elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.frame.size = CGSize(width: 90, height: 24)
        label.font = Fonts.playerProgressTimeFont
        label.textColor = UIColor(hex: "919191")
        label.textAlignment = .left
        return label
    }()
    
    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.frame.size = CGSize(width: 90, height: 24)
        label.font = Fonts.playerProgressTimeFont
        label.textColor = UIColor(hex: "919191")
        label.textAlignment = .right
        return label
    }()
    
    var currentTime: Float {
        get {
            return slider.value
        }
        set {
            UIView.animate(0.1) {
                self.slider.setValue(newValue, animated: true)
            }
        }
    }
    
    var duration: Float {
        get {
            return slider.maximumValue
        }
        set {
            slider.maximumValue = newValue
        }
    }
    
    var sliderMovedByUser: Bool {
        return slider.isTracking
    }
    
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
        
        addSubview(slider)
        addSubview(elapsedTimeLabel)
        addSubview(remainingTimeLabel)
        
        slider.addTarget(self, action: #selector(valueChanged(slider:event:)), for: .valueChanged)
    }
    
    private func layoutViews() {
        slider.frame.origin = .zero
        slider.frame.size = CGSize(width: frame.width, height: 28)
        
        elapsedTimeLabel.frame.origin.x = slider.frame.minX + 2
        elapsedTimeLabel.frame.origin.y = slider.center.y + UIProperties.Player.progressTimeTopInset
        
        remainingTimeLabel.frame.origin.x = slider.frame.maxX - remainingTimeLabel.frame.width - 2
        remainingTimeLabel.frame.origin.y = elapsedTimeLabel.frame.origin.y
    }
    
    @objc private func valueChanged(slider: UISlider, event: UIEvent) {
        guard let touchEvent = event.allTouches?.first else { return }
        switch touchEvent.phase {
        case .began:
            delegate?.sliderBeganDrag()
            
            UIView.animate(0.28) {
                self.elapsedTimeLabel.frame.origin.y = self.slider.center.y + 9
                self.remainingTimeLabel.frame.origin.y = self.slider.center.y + 9
                self.elapsedTimeLabel.textColor = Colors.roundButtonColor
            }
            
        case .moved:
            delegate?.sliderIsDragging()
            
        case .ended:
            delegate?.sliderEndedDrag()
            
            UIView.animate(0.28) {
                self.elapsedTimeLabel.frame.origin.y = self.slider.center.y + UIProperties.Player.progressTimeTopInset
                self.remainingTimeLabel.frame.origin.y = self.slider.center.y + UIProperties.Player.progressTimeTopInset
                self.elapsedTimeLabel.textColor = UIColor(hex: "919191")
            }
            
        default: break
        }
    }
    
    func setupElapsedTime(_ time: String) {
        elapsedTimeLabel.text = time
    }
    
    func setupRemainingTime(_ time: String) {
        remainingTimeLabel.text = time
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
