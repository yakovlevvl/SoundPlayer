//
//  NavigationInteractor.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 30.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class NavigationInteractor: UIPercentDrivenInteractiveTransition {
    
    private var shouldCompleteTransition = false
    private(set) var transitionInProgress = false
    
    private weak var navigationController: UINavigationController!
    
    private var swipeBackGesture: UIPanGestureRecognizer!
    
    init(navigationController: UINavigationController) {
        super.init()
        self.navigationController = navigationController
        setupBackGesture(view: navigationController.view)
    }
    
    private func setupBackGesture(view: UIView) {
        swipeBackGesture = UIPanGestureRecognizer(target: self, action: #selector(handleBackGesture(_:)))
        swipeBackGesture.delegate = self
        view.addGestureRecognizer(swipeBackGesture)
    }
    
    private func removeBackGesture() {
        navigationController.view.removeGestureRecognizer(swipeBackGesture)
    }
    
    @objc private func handleBackGesture(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: gesture.view)
        let translation = gesture.translation(in: gesture.view)
        let progress = translation.x / gesture.view!.frame.width * 0.5
        
        switch gesture.state {
        case .began :
            transitionInProgress = true
            navigationController.popViewController(animated: true)
        case .changed :
            shouldCompleteTransition = velocity.x > 0
            update(progress)
        case .cancelled :
            transitionInProgress = false
            cancel()
        case .ended :
            transitionInProgress = false
            completionSpeed = shouldCompleteTransition ? 1.0 : progress < 0.14 ? 0.18 : 0.3
            shouldCompleteTransition ? finish() : cancel()
        default : break
        }
    }
    
    deinit {
        removeBackGesture()
    }
}

extension NavigationInteractor: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: pan.view)
            return velocity.x > abs(velocity.y)
        }
        return true
    }
}
