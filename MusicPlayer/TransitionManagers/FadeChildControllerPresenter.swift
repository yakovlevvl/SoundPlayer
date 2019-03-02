//
//  FadeChildControllerPresenter.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 25.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class FadeChildControllerPresenter {
    
    var duration = 0.17
    
    private var childController: UIViewController!
    
    private weak var parentController: UIViewController!
    
    private let whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    init(parentController: UIViewController) {
        self.parentController = parentController
    }
    
    func present(_ viewController: UIViewController) {
        childController = viewController
        whiteView.alpha = 0
        whiteView.frame = parentController.view.bounds
        parentController.view.addSubview(whiteView)
        
        UIView.animate(duration, animation: {
            self.whiteView.alpha = 1
        }, completion: { _ in
            viewController.view.frame = self.parentController.view.bounds
            viewController.view.alpha = 0
            self.parentController.addChildController(viewController, parentView: self.whiteView)

            UIView.animate(self.duration) {
                viewController.view.alpha = 1
            }
        })
    }
    
    func dismiss() {
        if childController != nil, childController!.parent != nil {
            UIView.animate(duration, animation: {
                self.childController.view.alpha = 0
            }, completion: { _ in
                self.childController.removeFromParentVC()
                UIView.animate(self.duration, animation: {
                    self.whiteView.alpha = 0
                }, completion: { _ in
                    self.whiteView.removeFromSuperview()
                    self.childController = nil
                })
            })
        }
    }
}
