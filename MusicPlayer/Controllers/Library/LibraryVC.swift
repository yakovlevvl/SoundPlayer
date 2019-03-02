//
//  LibraryVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 08.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import CoreSpotlight

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
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        return scrollView
    }()
    
    private let transitionManager = BrowserTransitionManager()
    
    private var searchPresenter: FadeChildControllerPresenter!
    
    static let shared = LibraryVC(nibName: nil, bundle: nil)
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        topBar.delegate = self
        
        menuBar.delegate = self
        addChildController(menuBar)
        
        controllersView.delegate = self
        view.addSubview(controllersView)
        
        albumsVC.delegate = self
        playlistsVC.delegate = self
        
        for controller in controllers {
            let containerView = UIView()
            addChildController(controller, parentView: containerView)
            controllersView.addSubview(containerView)
        }
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        let topBarHeight: CGFloat = currentDevice == .iPhoneX ? 86 : 90
        topBar.frame.size = CGSize(width: view.frame.width, height: topBarHeight)
        
        menuBar.view.frame.size = CGSize(width: view.frame.width - 50, height: 40)
        menuBar.view.frame.origin.y = topBar.frame.maxY
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

extension LibraryVC: LibraryTopBarDelegate {
    
    func tapSearchButton() {
        let searchVC = SearchVC()
        searchVC.delegate = self
        searchPresenter = FadeChildControllerPresenter(parentController: self)
        searchPresenter.duration = 0.13
        searchPresenter.present(searchVC)
    }
}

extension LibraryVC: SearchDelegate {
    
    func didSelectSong(_ song: Song) {
        Player.main.play(song: song)
    }
    
    func tapCancelButton() {
        searchPresenter.dismiss()
    }
}

extension LibraryVC: AlbumsDelegate {
    
    func didSelectAlbum(_ album: Album) {
        let albumVC = AlbumVC()
        albumVC.album = album
        navigationController?.pushViewController(albumVC, animated: true)
    }
}

extension LibraryVC: PlaylistsDelegate {
    
    func didSelectPlaylist(_ playlist: Playlist) {
        let playlistVC = PlaylistVC()
        playlistVC.playlist = playlist
        navigationController?.pushViewController(playlistVC, animated: true)
    }
}

extension LibraryVC {
    
    func updateSongsView() {
        songsVC.updateSongsView()
    }
    
    func updateAlbumsView() {
        albumsVC.updateAlbumsView()
    }
    
    func updatePlaylistsView() {
        playlistsVC.updatePlaylistsView()
    }
}

extension LibraryVC: BrowserDelegate {
    
    func browserDownloadedSong() {
        songsVC.updateSongsView()
    }
}

extension LibraryVC {
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        if activity.activityType == CSSearchableItemActionType {
            guard let userInfo = activity.userInfo else { return }
            
            let uniqueId = userInfo[CSSearchableItemActivityIdentifier] as! String
            let uniqueIdComponents = uniqueId.components(separatedBy: ":")
            
            guard uniqueIdComponents.count == 2 else { return }
            
            let itemId = uniqueIdComponents.last!
            guard let domainId = SpotlightDomainId(rawValue: uniqueIdComponents.first!) else { return }
            
            switch domainId {
            case .songs :
                guard let song = library.song(with: itemId) else { return }
                didSelectSong(song)
            case .albums :
                guard let album = library.album(with: itemId) else { return }
                navigationController!.popToViewController(self, animated: true)
                didSelectAlbum(album)
            case .playlists :
                guard let playlist = library.playlist(with: itemId) else { return }
                navigationController!.popToViewController(self, animated: true)
                didSelectPlaylist(playlist)
            }
        }
    }
}


