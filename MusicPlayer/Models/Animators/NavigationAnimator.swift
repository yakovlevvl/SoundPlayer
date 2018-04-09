//
//  NavigationAnimator.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 24.03.2018.
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

class NavigationInteractor: UIPercentDrivenInteractiveTransition {
    
    var transitionInProgress = false
    var shouldCompleteTransition = false
    let navigationController: UINavigationController
    
    var swipeBackGesture: UIPanGestureRecognizer!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
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
            return velocity.x > fabs(velocity.y)
        }
        return true
    }
}

class NavigationTransitionManager: NSObject {
    
    let animator = NavigationAnimator()
    var interactor: NavigationInteractor?
}

extension NavigationTransitionManager: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push :
            animator.presenting = true
            return animator
        default :
            animator.presenting = false
            return animator
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactor = interactor else { return nil }
        return interactor.transitionInProgress ? interactor : nil
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == navigationController.viewControllers.first! {
            interactor = nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        interactor = NavigationInteractor(navigationController: navigationController)
    }
}
