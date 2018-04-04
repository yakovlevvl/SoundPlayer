//
//  BaseVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 24.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BaseVC: UIViewController {
    
    private let tabBar = TabBar()
    
    private let contentView = UIView()
    
    private let libraryNC = UINavigationController(rootViewController: LibraryVC())
    
    private let browserVC = BrowserVC()
    
    private let settingsVC = SettingsVC()
    
    private let transitionManager = BrowserTransitionManager()

    private let navigationManager = NavigationTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        tabBar.delegate = self
        view.addSubview(tabBar)
        
        view.addSubview(contentView)
        contentView.backgroundColor = .white
        
        layoutViews()
        
        showInitialController()
        
        libraryNC.delegate = navigationManager
        libraryNC.isNavigationBarHidden = true
        browserVC.delegate = libraryNC.viewControllers.first as! LibraryVC
        browserVC.transitioningDelegate = transitionManager
    }
    
    private func layoutViews() {
        let tabBarHeight: CGFloat = 62
        
        tabBar.frame.origin.x = 0
        tabBar.frame.size.width = view.frame.width
        tabBar.frame.size.height = tabBarHeight
        tabBar.frame.origin.y = view.frame.height - tabBarHeight
        
        contentView.frame.origin = .zero
        contentView.frame.size.width = view.frame.width
        contentView.frame.size.height = view.frame.height - tabBarHeight
    }
    
    private func showController(_ vc: UIViewController) {
        if vc.parent != nil { return }
        childViewControllers.first?.removeFromParent()
        addChildController(vc, parentView: contentView)
        vc.view.frame = contentView.bounds
        vc.view.alpha = 0
        
        UIView.animate(0.15, animation: {
            vc.view.alpha = 1
        }, completion: { finished in
            if !finished { return }
            
        })
    }
    
    private func showInitialController() {
        showController(libraryNC)
    }


}

extension BaseVC: TabBarDelegate {
    
    func tapBrowserButton() {
        present(browserVC, animated: true)
    }
    
    func tapLibraryButton() {
        showController(libraryNC)
    }
    
    func tapSettingsButton() {
        showController(settingsVC)
    }
}
