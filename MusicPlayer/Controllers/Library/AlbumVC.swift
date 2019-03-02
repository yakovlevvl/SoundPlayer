//
//  AlbumVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 19.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class CompilationVC: UIViewController {

    fileprivate let player = Player.main
    
    fileprivate let library = Library.main
    
    fileprivate let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.setRightButtonFont(Fonts.clearTopBarFont)
        topBar.setRightButtonTitle("Edit")
        topBar.setRightButtonTitleColor(Colors.red)
        topBar.setLeftButtonImage(UIImage(named: "BackIcon"))
        return topBar
    }()
    
    fileprivate let songsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 16
        layout.minimumLineSpacing = 14
        layout.itemSize = CGSize(width: screenWidth - 32, height: UIProperties.songCellHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    let transitionManager = VerticalTransitionManager()
    
    fileprivate var editPresenter: FadeChildControllerPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        songsView.reloadData()
        player.currentSong != nil ? playerBarAppeared() : playerBarDisappeared()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
    
        view.addSubview(topBar)
        view.insertSubview(songsView, at: 0)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapBackButton()
        }
        topBar.onRightButtonTapped = { [unowned self] in
            self.tapEditButton()
        }
        
        songsView.delegate = self
        songsView.dataSource = self
        songsView.register(SongCell.self, forCellWithReuseIdentifier: SongCell.reuseId)
        registerSupplementaryViewClass()
        
        setupPlayerBarObserver()
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 76)
        
        if #available(iOS 11.0, *) {
            songsView.contentInsetAdjustmentBehavior = .never
        }
        
        songsView.frame = view.bounds
        songsView.contentInset.top = topBar.frame.height + 2
        songsView.scrollIndicatorInsets.top = songsView.contentInset.top
        
        let layout = songsView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: songsView.frame.width, height: UIProperties.CompilationView.height)
    }
    
    fileprivate func registerSupplementaryViewClass() {}
    
    fileprivate func tapEditButton() {}
    
    fileprivate func setDefaultTitle() {}
    
    fileprivate func setCompilationTitle() {}
    
    func tapMoreButton(_ cell: SongCell) {}
    
    private func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func updatePlayerBar() {
        if let baseVC = UIApplication.shared.windows.first?.rootViewController as? BaseVC {
            baseVC.updatePlayerBar()
        }
    }
    
    deinit {
        removePlayerBarObserver()
    }
}

extension CompilationVC: SongCellDelegate {}

extension CompilationVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
}

extension CompilationVC: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let topInset = scrollView.contentInset.top
        if yOffset > -topInset {
            topBar.makeOpaque(with: Colors.clearWhite)
        } else {
            topBar.makeTransparent()
        }
        if yOffset > -topInset + 32 {
            setCompilationTitle()
            //topBar.showTitle()
        } else {
            setDefaultTitle()
            //topBar.hideTitle()
        }
    }
}

extension CompilationVC: PlayerBarObservable {
    
    func playerBarAppeared() {
        songsView.contentInset.bottom = UIProperties.playerBarHeight
        songsView.scrollIndicatorInsets.bottom = UIProperties.playerBarHeight
    }
    
    func playerBarDisappeared() {
        songsView.contentInset.bottom = 0
        songsView.scrollIndicatorInsets.bottom = 0
    }
}


final class PlaylistVC: CompilationVC {
    
    var playlist: Playlist!
    
    override func registerSupplementaryViewClass() {
        songsView.register(PlaylistView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistView.reuseId)
    }
    
    override func setDefaultTitle() {
        topBar.title = "Playlist"
    }
    
    override func setCompilationTitle() {
        topBar.title = playlist.title
    }
    
    override func tapEditButton() {
        let editPlaylistVC = EditPlaylistVC()
        editPlaylistVC.playlist = playlist
        editPlaylistVC.editPlaylistDelegate = self
        editPlaylistVC.addedSongs = Array(playlist.songs)
        editPresenter = FadeChildControllerPresenter(parentController: self)
        editPresenter.present(editPlaylistVC)
    }
    
    override func tapMoreButton(_ cell: SongCell) {
        guard let indexPath = songsView.indexPath(for: cell) else { return }
        let song = playlist.songs[indexPath.item]
        showActions(for: song, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlist.songs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.reuseId, for: indexPath) as! SongCell
        cell.delegate = self
        cell.setup(for: playlist.songs[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let playlistView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistView.reuseId, for: indexPath) as! PlaylistView
        playlistView.delegate = self
        playlistView.setupTitle(playlist.title)
        playlist.getArtworkAsync { artwork in
            playlistView.setupArtworkImage(artwork)
        }
        return playlistView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        player.playSong(with: indexPath.item, in: Array(playlist.songs))
    }
}

extension PlaylistVC: EditPlaylistDelegate {
    
    func editedPlaylist() {
        songsView.reloadData()
        editPresenter.dismiss()
        updatePlaylistsView()
        updatePlayerBar()
    }
    
    func tappedCloseButton() {
        editPresenter.dismiss()
    }
    
    private func updatePlaylistsView() {
        let libraryVC = navigationController!.viewControllers.first as! LibraryVC
        libraryVC.updatePlaylistsView()
    }
}

extension PlaylistVC: PlaylistSongActions {
    
    func renameSong(_ song: Song, with name: String, at indexPath: IndexPath) {
        library.renameSong(song, with: name) {
            self.songsView.reloadItems(at: [indexPath])
            if self.player.currentSong == song {
                self.updatePlayerBar()
            }
            if SettingsManager.spotlightIsEnabled {
                SpotlightManager.indexSong(song)
            }
        }
    }
    
    func removeSongFromPlaylist(_ song: Song, at indexPath: IndexPath) {
        if player.originalSongsList == Array(playlist.songs) {
            player.removeSongFromSongsList(with: indexPath.item)
        }
        library.removeSongFromPlaylist(song, playlist: playlist) {
            self.songsView.deleteItems(at: [indexPath])
        }
    }
}

extension PlaylistVC: PlaylistViewDelegate {
    
    func tapMoreButton() {
        let actionSheet = RoundActionSheet()
        let removeAction = Action(title: "Delete", type: .destructive) {
            self.removePlaylist()
        }
        actionSheet.addAction(removeAction)
        actionSheet.present()
    }
    
    private func removePlaylist() {
        if player.originalSongsList == Array(playlist.songs) {
            player.clearSongsList()
        }
        if SettingsManager.spotlightIsEnabled {
            SpotlightManager.removePlaylist(playlist)
        }
        library.removePlaylist(playlist) {
            self.updatePlaylistsView()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tapPlayButton() {
        player.playSongsList(Array(playlist.songs))
    }
    
    func tapShuffleButton() {
        player.shuffleAndPlaySongsList(Array(playlist.songs))
    }
}


final class AlbumVC: CompilationVC {

    var album: Album!

    override func registerSupplementaryViewClass() {
        songsView.register(AlbumView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AlbumView.reuseId)
    }
    
    override func setDefaultTitle() {
        topBar.title = "Album"
    }
    
    override func setCompilationTitle() {
        topBar.title = album.title
    }
    
    override func tapEditButton() {
        let editAlbumVC = EditAlbumVC()
        editAlbumVC.album = album
        editAlbumVC.editAlbumDelegate = self
        editAlbumVC.addedSongs = Array(album.songs)
        editPresenter = FadeChildControllerPresenter(parentController: self)
        editPresenter.present(editAlbumVC)
    }
    
    override func tapMoreButton(_ cell: SongCell) {
        guard let indexPath = songsView.indexPath(for: cell) else { return }
        let song = album.songs[indexPath.item]
        showActions(for: song, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.songs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.reuseId, for: indexPath) as! SongCell
        cell.delegate = self
        cell.setup(for: album.songs[indexPath.item])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let albumView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AlbumView.reuseId, for: indexPath) as! AlbumView
        albumView.delegate = self
        albumView.setupTitle(album.title)
        albumView.setupArtist(album.artist)
        album.getArtworkAsync { artwork in
            albumView.setupArtworkImage(artwork)
        }
        return albumView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        player.playSong(with: indexPath.item, in: Array(album.songs))
    }
}

extension AlbumVC: EditAlbumDelegate {
    
    func editedAlbum() {
        songsView.reloadData()
        editPresenter.dismiss()
        updateAlbumsView()
        updatePlayerBar()
    }
    
    func tappedCloseButton() {
        editPresenter.dismiss()
    }
    
    private func updateAlbumsView() {
        let libraryVC = navigationController!.viewControllers.first as! LibraryVC
        libraryVC.updateAlbumsView()
    }
    
    private func updatePlaylistsView() {
        let libraryVC = navigationController!.viewControllers.first as! LibraryVC
        libraryVC.updatePlaylistsView()
    }
}

extension AlbumVC: AlbumSongActions {
    
    func removeSongFromAlbum(_ song: Song, at indexPath: IndexPath) {
        if player.originalSongsList == Array(album.songs) {
            player.removeSongFromSongsList(with: indexPath.item)
        }
        library.removeSongFromAlbum(song) {
            self.songsView.deleteItems(at: [indexPath])
            if self.player.currentSong == song {
                self.updatePlayerBar()
            }
            if SettingsManager.spotlightIsEnabled {
                SpotlightManager.indexSong(song)
            }
        }
    }
    
    func renameSong(_ song: Song, with name: String, at indexPath: IndexPath) {
        library.renameSong(song, with: name) {
            self.songsView.reloadItems(at: [indexPath])
            if self.player.currentSong == song {
                self.updatePlayerBar()
            }
            if SettingsManager.spotlightIsEnabled {
                SpotlightManager.indexSong(song)
            }
        }
    }
    
    func removeSong(_ song: Song, at indexPath: IndexPath) {
        let checkPlaylists = !song.playlists.isEmpty
        player.removeSongFromSongsList(song: song)
        if SettingsManager.spotlightIsEnabled {
            SpotlightManager.removeSong(song)
        }
        library.removeSong(song) {
            self.songsView.deleteItems(at: [indexPath])
            if checkPlaylists {
                self.library.removeEmptyPlaylists { removed in
                    if removed {
                        self.updatePlaylistsView()
                    }
                }
            }
        }
    }
}

extension AlbumVC: AlbumViewDelegate {
    
    func tapMoreButton() {
        let actionSheet = RoundActionSheet()
        let removeAction = Action(title: "Delete", type: .destructive) {
            self.removeAlbum()
        }
        let addToPlaylistAction = Action(title: "Add to Playlist", type: .normal) { 
            self.selectPlaylist(for: Array(self.album.songs))
        }
        actionSheet.addAction(addToPlaylistAction)
        actionSheet.addAction(removeAction)
        actionSheet.present()
    }
    
    private func removeAlbum() {
        let albumSongs = Array(album.songs)
        if player.originalSongsList == albumSongs {
            player.clearSongsList()
        }
        if SettingsManager.spotlightIsEnabled {
            SpotlightManager.removeAlbum(album)
        }
        library.removeAlbum(album) {
            self.updateAlbumsView()
            self.updatePlayerBar()
            self.navigationController?.popViewController(animated: true)
            if SettingsManager.spotlightIsEnabled {
                SpotlightManager.indexSongs(albumSongs)
            }
        }
    }
    
    private func selectPlaylist(for songs: [Song]) {
        let selectPlaylistVC = SelectPlaylistVC()
        selectPlaylistVC.songs = songs
        selectPlaylistVC.transitioningDelegate = transitionManager
        present(selectPlaylistVC, animated: true)
    }
    
    func tapPlayButton() {
        player.playSongsList(Array(album.songs))
    }
    
    func tapShuffleButton() {
        player.shuffleAndPlaySongsList(Array(album.songs))
    }
}

