//
//  LibraryVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 08.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class LibraryVC: UIViewController {
    
    private let library = Library.main
    
    private let topBar = LibraryTopBar()
    
    private let menuBar = LibraryMenuBar()
    
    private let songsVC = SongsVC()
    
    private let albumsVC = AlbumsVC()
    
    private let playlistsVC = PlaylistsVC()
    
    private lazy var controllers = [albumsVC, songsVC, playlistsVC]
    
    private let controllersView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        return scrollView
    }()
    
    private let transitionManager = BrowserTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        
        menuBar.delegate = self
        addChildController(menuBar)
        
        controllersView.delegate = self
        view.addSubview(controllersView)
        
        albumsVC.delegate = self
        
        for controller in controllers {
            let containerView = UIView()
            addChildController(controller, parentView: containerView)
            controllersView.addSubview(containerView)
        }
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 90)
        
        menuBar.view.frame.size = CGSize(width: view.frame.width - 50, height: 40)
        menuBar.view.frame.origin.y = topBar.frame.height
        menuBar.view.center.x = view.center.x
        
        var rect = CGRect()
        rect.origin = CGPoint(x: 0, y: menuBar.view.frame.maxY)
        rect.size = CGSize(width: view.frame.width, height: view.frame.height - rect.origin.y)
        
        controllersView.frame = rect
        controllersView.contentSize.height = rect.height
        controllersView.contentSize.width = rect.width*CGFloat(controllers.count)
        
        for (index, container) in controllersView.subviews.enumerated() {
            container.frame.size = rect.size
            container.frame.origin.y = 0
            container.frame.origin.x = rect.width*CGFloat(index)
            let controllerView = container.subviews.first
            controllerView?.frame.origin = .zero
            controllerView?.frame.size = rect.size
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    private func showViewController(_ vc: UIViewController) {
        guard let index = controllers.index(of: vc) else { return }
        let position = controllersView.frame.width*CGFloat(index)
        UIView.animate(0.4, damping: 0.95, velocity: 1) {
            self.controllersView.contentOffset.x = position
        }
    }

    
}

extension LibraryVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.contentSize.width
        let position = value*menuBar.view.frame.width
        menuBar.setupMarkerView(with: position, animated: false)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x/scrollView.frame.width
        menuBar.selectItem(at: Int(index))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = scrollView.contentOffset.x/scrollView.frame.width
        menuBar.selectItem(at: Int(index))
    }
}

extension LibraryVC: LibraryMenuBarDelegate {
    
    func didSelectMenuItem(_ item: LibraryItems) {
        switch item {
        case .songs : showViewController(songsVC)
        case .albums : showViewController(albumsVC)
        case .playlists : showViewController(playlistsVC)
        }
    }
}

extension LibraryVC: AlbumsDelegate {
    
    func didSelectAlbum(_ album: Album) {
        let albumVC = AlbumVC()
        albumVC.album = album
        navigationController?.pushViewController(albumVC, animated: true)
    }
    
    func updateAlbumsView() {
        albumsVC.updateAlbumsView()
    }
}

extension LibraryVC: BrowserDelegate {
    
    func browserDownloadedSong() {
        songsVC.updateSongsView()
    }
}
