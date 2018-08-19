//
//  VerticalTransitionAnimator.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 30.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class VerticalTransitionAnimator: NSObject {
    
    var presenting = true
    let presentDuration = 0.45
    let dismissDuration = 0.28
    var cornerRadius: CGFloat = 0
}

extension VerticalTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presenting ? presentDuration : dismissDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        if presenting {
            containerView.addSubview(toView)
            toView.frame.origin.y = screenHeight
            animatePresenting(fromView: fromView, toView: toView) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            containerView.insertSubview(toView, at: 0)
            animateDismissing(fromView: fromView, toView: toView) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private func animatePresenting(fromView: UIView, toView: UIView, completion: @escaping () -> ()) {
        toView.layer.masksToBounds = true
        fromView.layer.masksToBounds = true
        UIView.animate(presentDuration, damping: 1, velocity: 1, animation: {
            fromView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            fromView.layer.cornerRadius = self.cornerRadius
            toView.frame.origin.y = 0
            if self.cornerRadius != 0 {
                toView.layer.cornerRadius = self.cornerRadius
            }
        }, completion: { _ in
            completion()
        })
    }
    
    private func animateDismissing(fromView: UIView, toView: UIView, completion: @escaping () -> ()) {
        UIView.animate(dismissDuration, animation: {
            toView.transform = .identity
            if self.cornerRadius != 0 {
                toView.layer.cornerRadius = 0
            }
            fromView.frame.origin.y = screenHeight
        }, completion: { _ in
            completion()
        })
    }
}
