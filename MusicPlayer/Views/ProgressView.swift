//
//  ProgressView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 31.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class ProgressView: UIView {
    
    var progress: Double = 0 {
        didSet {
            if progress > 1 {
                progress = 1
            }
            if progress < oldValue {
                progressView.alpha = 1
                progressView.frame.size.width = 0
            }
            animateProgress(with: progress)
        }
    }
    
    var trackColor = UIColor.clear {
        didSet {
            backgroundColor = trackColor
        }
    }
    
    var progressColor = UIColor.blue {
        didSet {
            progressView.backgroundColor = progressColor
        }
    }
    
    private let progressView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = trackColor
        progressView.backgroundColor = progressColor
        
        progressView.frame = bounds
        progressView.frame.size.width = 0
        
        addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame.size.height = frame.height
    }
    
    private func animateProgress(with value: Double) {
        UIView.animate(0.4, options: .curveEaseOut) {
            self.progressView.frame.size.width = self.frame.width*CGFloat(value)
            if value == 1 {
                self.progressView.alpha = 0
            }
        }
    }
    
    func setupProgressWithoutAnimation(with value: Double) {
        progressView.frame.size.width = frame.width*CGFloat(value)
        if value == 1 {
            progressView.alpha = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

