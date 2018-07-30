//
//  VerticalTransitionManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 30.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class VerticalTransitionManager: NSObject {
    
    var cornerRadius: CGFloat = 0
    
    private let animator = VerticalTransitionAnimator()
    
    private var interactor: VerticalTransitionInteractor?
    
    init(viewController: UIViewController) {
        super.init()
        interactor = VerticalTransitionInteractor(viewController: viewController)
    }
    
    override init() {
        super.init()
    }
}

extension VerticalTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.cornerRadius = cornerRadius
        animator.presenting = true
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactor = interactor else { return nil }
        return interactor.transitionInProgress ? interactor : nil
    }
}
