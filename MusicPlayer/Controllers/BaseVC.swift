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
    
    private weak var playerVC: PlayerVC?
    
    private let playerBar = MiniPlayerBar()
    
    private let contentView = UIView()
    
    private let browserVC = BrowserVC()
    
    private let libraryNC = UINavigationController(rootViewController: LibraryVC.shared)
    
    private let settingsNC = UINavigationController(rootViewController: SettingsVC())
    
    private let transitionManager = BrowserTransitionManager()

    private let navigationManager = NavigationTransitionManager()
    
    private var verticalTransitionManager: VerticalTransitionManager! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePlayerBar()
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
        
        settingsNC.isNavigationBarHidden = true
        libraryNC.isNavigationBarHidden = true
        libraryNC.delegate = navigationManager
        settingsNC.delegate = navigationManager
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
    }
    
    private func showInitialController() {
        showController(libraryNC)
    }
    
    func showPlayerBar() {
        view.bringSubview(toFront: tabBar)
        UIView.animate(0.48, damping: 0.9, velocity: 1) {
            self.playerBar.frame.origin.y = screenHeight - self.playerBar.frame.height - self.tabBar.frame.height
        }
        NotificationCenter.default.post(name: .PlayerBarAppeared, object: nil)
    }
    
    func hidePlayerBar() {
        view.bringSubview(toFront: tabBar)
        UIView.animate(0.4) {
            self.playerBar.frame.origin.y = screenHeight
        }
        NotificationCenter.default.post(name: .PlayerBarDisappeared, object: nil)
    }
    
    func updatePlayerBar() {
        if let song = player.currentSong, !song.isInvalidated {
            playerBar.setupTitle(song.title)
            playerBar.setupArtwork(song.artwork)
            if player.isPlaying {
                playerBar.showPauseButton()
            } else {
                playerBar.showPlayButton()
            }
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
        showController(settingsNC)
    }
}

extension BaseVC: MiniPlayerBarDelegate {
    
    func tapNextButton() {
        player.playNextSong()
    }
    
    func tapPlayPauseButton() {
        player.isPlaying ? player.pause() : player.play()
    }

    func tapPlayerBar() {
        let playerVC = PlayerVC()
        self.playerVC = playerVC
        verticalTransitionManager = VerticalTransitionManager(viewController: playerVC)
        playerVC.transitioningDelegate = verticalTransitionManager
        present(playerVC, animated: true)
    }
}

extension BaseVC: PlayerDelegate {
    
    func playerStopped() {
        hidePlayerBar()
        playerVC?.dismiss(animated: true)
    }
    
    func playerPausedSong(_ song: Song) {
        updatePlayerBar()
        playerVC?.updateViews()
    }
    
    func playerResumedSong(_ song: Song) {
        showPlayerBar()
        updatePlayerBar()
        playerVC?.updateViews()
    }
    
    func playerUpdatedSongCurrentTime(currentTime: Float) {
        playerVC?.updateProgressView()
    }
    
    func playerFailedSong(_ song: Song) {
        let alertVC = AlertController(message: "Cannot play \"\(song.title)\"")
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        alertVC.addAction(Action(title: "Okay", type: .cancel))
        alertVC.present()
    }
}
