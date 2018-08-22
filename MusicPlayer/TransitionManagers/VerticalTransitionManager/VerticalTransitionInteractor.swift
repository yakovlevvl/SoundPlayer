//
//  VerticalTransitionInteractor.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 30.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class VerticalTransitionInteractor: UIPercentDrivenInteractiveTransition {
    
    private var shouldCompleteTransition = false
    private(set) var transitionInProgress = false
    
    private weak var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        setupGestureRecognizer(view: viewController.view)
    }
    
    private func setupGestureRecognizer(view: UIView) {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: gesture.view!.superview!)
        let translation = gesture.translation(in: gesture.view!.superview!)
        let progress = translation.y / gesture.view!.frame.height
        
        switch gesture.state {
        case .began :
            transitionInProgress = true
            viewController.dismiss(animated: true)
        case .changed :
            shouldCompleteTransition = velocity.y > 0
            update(progress)
        case .cancelled :
            transitionInProgress = false
            cancel()
        case .ended :
            transitionInProgress = false
            completionSpeed = shouldCompleteTransition ? 0.44 : progress < 0.14 ? 0.18 : 0.3
            shouldCompleteTransition ? finish() : cancel()
        default : break
        }
    }
}

extension VerticalTransitionInteractor: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: pan.view)
            return velocity.y > fabs(velocity.x)
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view! is UISlider || touch.view! is UIButton)
    }
}
