//
//  BrowserTransitionManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 08.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class BrowserTransitionAnimator: UIPercentDrivenInteractiveTransition {
    
    var presenting = true
    let presentDuration = 0.42
    let dismissDuration = 0.45
    
    private var interactive = false
    
    private var enterPanGesture: UIPanGestureRecognizer!
    
    var sourceViewController: UIViewController! {
        didSet {
            self.enterPanGesture = UIPanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action: #selector(handleOnstagePan(pan:)))
            //self.enterPanGesture.edges = .left
            //self.sourceViewController.view.addGestureRecognizer(self.enterPanGesture)
        }
    }
    
    @objc func handleOnstagePan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: pan.view?.superview)
        
        // do some math to translate this to a percentage based value
        let d = translation.x / pan.view!.bounds.width * 0.5
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.began:
            // set our interactive flag to true
            self.interactive = true
            
            // trigger the start of the transition
            (self.sourceViewController as! BaseVC).tapBrowserButton()
            break
            
        case UIGestureRecognizerState.changed:
            
            // update progress of the transition
            self.update(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            self.finish()
        }
    }
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

class BrowserTransitionManager: NSObject {
    
    let animator = BrowserTransitionAnimator()
    
    var sourceViewController: UIViewController {
        get {
            return animator.sourceViewController
        }
        set {
            animator.sourceViewController = newValue
        }
    }
}

extension BrowserTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = true
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }
    
//    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return animator as? UIViewControllerInteractiveTransitioning
//    }
//
//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return animator as? UIViewControllerInteractiveTransitioning
//    }
}

