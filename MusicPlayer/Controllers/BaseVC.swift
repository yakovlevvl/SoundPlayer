//
//  BaseVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 24.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BaseVC: UIViewController {
    
    private let player = Player.main
    
    private let tabBar = TabBar()
    
    private let playerBar = MiniPlayerBar()
    
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
        
        player.delegate = self
        playerBar.delegate = self
        view.addSubview(playerBar)
        
        view.addSubview(contentView)
        contentView.backgroundColor = .white
        
        view.bringSubview(toFront: playerBar)
        
        layoutViews()
        
        showInitialController()
        
        libraryNC.isNavigationBarHidden = true
        libraryNC.delegate = navigationManager
        browserVC.transitioningDelegate = transitionManager
        browserVC.delegate = libraryNC.viewControllers.first as! LibraryVC
    }
    
    private func layoutViews() {
        let tabBarHeight: CGFloat = 62
        let playerBarHeight = PlayerBarProperties.barHeight
        
        tabBar.frame.origin.x = 0
        tabBar.frame.size.width = view.frame.width
        tabBar.frame.size.height = tabBarHeight
        tabBar.frame.origin.y = view.frame.height - tabBarHeight
        
        contentView.frame.origin = .zero
        contentView.frame.size.width = view.frame.width
        contentView.frame.size.height = view.frame.height - tabBarHeight
        
        playerBar.frame.origin.x = 0
        playerBar.frame.size = CGSize(width: view.frame.width, height: playerBarHeight)
        playerBar.frame.origin.y = view.frame.height
    }
    
    private func showController(_ vc: UIViewController) {
        if vc.parent != nil { return }
        childViewControllers.first?.removeFromParent()
        addChildController(vc, parentView: contentView)
        vc.view.frame = contentView.bounds
        
        //vc.view.alpha = 0
        
//        UIView.animate(0.18, animation: {
//            vc.view.alpha = 1
//        }, completion: { finished in
//            if !finished { return }
//
//        })
    }
    
    private func showInitialController() {
        showController(libraryNC)
    }
    
    func showPlayerBar() {
        view.bringSubview(toFront: tabBar)
        UIView.animate(0.48, damping: 0.9, velocity: 1) {
            self.playerBar.frame.origin.y = self.view.frame.height - self.playerBar.frame.height - self.tabBar.frame.height
        }
    }
    
    func hidePlayerBar() {
        view.bringSubview(toFront: tabBar)
        UIView.animate(0.4) {
            self.playerBar.frame.origin.y = self.view.frame.height
        }
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

extension BaseVC: MiniPlayerBarDelegate {
    
    func tapNextButton() {
        player.playNextSong()
    }
    
    func tapPlayPauseButton() {
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    func tapPlayerBar() {
        print("show player controller")
    }
}

extension BaseVC: PlayerDelegate {
    
    func playerPausedSong(_ song: Song) {
        playerBar.showPlayButton()
    }
    
    func playerResumedSong(_ song: Song) {
        showPlayerBar()
        playerBar.showPauseButton()
        playerBar.setupTitle(song.title)
        playerBar.setupArtwork(song.artwork)
    }
    
    func playerFailedSong(_ song: Song) {
        playerBar.showPlayButton()
        playerBar.setupTitle(song.title)
        playerBar.setupArtwork(song.artwork)
        let alertVC = AlertController(message: "Cannot play \"\(song.title)\"")
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        alertVC.addAction(Action(title: "Okay", type: .cancel))
        alertVC.present()
    }
    
//    func playerChangedVolume(to value: Float) {
//        print("playerChangedVolume")
//    }
//
//    func playerUpdatedSongCurrentTime(elapsedTime: String, remainingTime: String) {
//        print("playerUpdatedSongCurrentTime")
//    }
}
