//
//  NavigationAnimator.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 30.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class NavigationAnimator: NSObject {
    
    var presenting = true
    let popDuration = 0.48
    let pushDuration = 0.42
}

extension NavigationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presenting ? pushDuration : popDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        if presenting {
            containerView.addSubview(toView)
            toView.frame.origin.x = screenWidth
            animatePresenting(fromView: fromView, toView: toView) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            toView.frame.origin.x = -fromView.frame.width/3
            containerView.insertSubview(toView, belowSubview: fromView)
            animateDismissing(fromView: fromView, toView: toView) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private func animatePresenting(fromView: UIView, toView: UIView, completion: @escaping () -> ()) {
        toView.alpha = 0.3
        UIView.animate(pushDuration, damping: 0.98, velocity: 1, animation: {
            toView.frame.origin.x = 0
            fromView.frame.origin.x = -fromView.frame.width/3
            toView.alpha = 1
            fromView.alpha = 0
        }, completion: { _ in
            completion()
        })
    }
    
    private func animateDismissing(fromView: UIView, toView: UIView, completion: @escaping () -> ()) {
        toView.alpha = 0
        UIView.animate(popDuration, damping: 0.98, velocity: 1, animation: {
            fromView.frame.origin.x = screenWidth
            toView.frame.origin.x = 0
            fromView.alpha = 0
            toView.alpha = 1
        }, completion: { _ in
            completion()
        })
    }
}

