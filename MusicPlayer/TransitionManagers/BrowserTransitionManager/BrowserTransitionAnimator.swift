//
//  BrowserTransitionAnimator.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 30.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class BrowserTransitionAnimator: NSObject {
    
    var presenting = true
    let presentDuration = 0.42
    let dismissDuration = 0.45
}

extension BrowserTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presenting ? presentDuration : dismissDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        containerView.backgroundColor = .white
        
        if presenting {
            containerView.addSubview(toView)
            toView.frame.origin.x = -screenWidth
            animatePresenting(fromView: fromView, toView: toView) {
                transitionContext.completeTransition(true)
                containerView.backgroundColor = .black
            }
        } else {
            toView.frame.origin.x = fromView.frame.width/3
            containerView.insertSubview(toView, belowSubview: fromView)
            animateDismissing(fromView: fromView, toView: toView) {
                transitionContext.completeTransition(true)
                containerView.backgroundColor = .black
            }
        }
    }
    
    private func animatePresenting(fromView: UIView, toView: UIView, completion: @escaping () -> ()) {
        toView.alpha = 0.3
        UIView.animate(presentDuration, damping: 0.98, velocity: 1, animation: {
            toView.alpha = 1
            toView.frame.origin.x = 0
            fromView.alpha = 0
            fromView.frame.origin.x = fromView.frame.width/3
        }, completion: { _ in
            completion()
        })
    }
    
    private func animateDismissing(fromView: UIView, toView: UIView, completion: @escaping () -> ()) {
        toView.alpha = 0
        UIView.animate(dismissDuration, damping: 0.98, velocity: 1, animation: {
            toView.alpha = 1
            fromView.alpha = 0
            toView.frame.origin.x = 0
            fromView.frame.origin.x = -screenWidth
        }, completion: { _ in
            completion()
        })
    }
}

