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
        topBar.setRightButtonFontSize(20)
        topBar.setRightButtonTitle("Edit")
        topBar.setRightButtonTitleColor(Colors.red)
        topBar.setLeftButtonImage(UIImage(named: "BackIcon"))
        return topBar
    }()
    
    fileprivate let songsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 16
        layout.minimumLineSpacing = 14
        layout.itemSize = CGSize(width: screenWidth - 32, height: 70)
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
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 76)
        
        songsView.frame = view.bounds
        songsView.contentInset.top = topBar.frame.height + 2
        songsView.scrollIndicatorInsets.top = songsView.contentInset.top
        
        let layout = songsView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: songsView.frame.width, height: 226)
    }
    
    fileprivate func registerSupplementaryViewClass() {}
    
    fileprivate func tapEditButton() {}
    
    fileprivate func setDefaultTitle() {}
    
    fileprivate func setCompilationTitle() {}
    
    func tapMoreButton(_ cell: SongCell) {}
    
    private func tapBackButton() {
        navigationController?.popViewController(animated: true)
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


final class PlaylistVC: CompilationVC {
    
    var playlist: Playlist!
    
    override func registerSupplementaryViewClass() {
        songsView.register(PlaylistView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PlaylistView.reuseId)
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
        let playlistView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PlaylistView.reuseId, for: indexPath) as! PlaylistView
        playlistView.delegate = self
        playlistView.setupTitle(playlist.title)
        playlist.getArtworkAsync { artwork in
            playlistView.setupArtworkImage(artwork)
        }
        return playlistView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let song = playlist.songs[indexPath.item]
        player.playSong(song)
        player.songsList = Array(playlist.songs)
    }
}

extension PlaylistVC: EditPlaylistDelegate {
    
    func editedPlaylist() {
        songsView.reloadData()
        editPresenter.dismiss()
        updatePlaylistsView()
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
        }
    }
    
    func removeSongFromPlaylist(_ song: Song, at indexPath: IndexPath) {
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
        songsView.register(AlbumView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AlbumView.reuseId)
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
        let albumView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AlbumView.reuseId, for: indexPath) as! AlbumView
        albumView.delegate = self
        albumView.setupTitle(album.title)
        albumView.setupArtist(album.artist)
        album.getArtworkAsync { artwork in
            albumView.setupArtworkImage(artwork)
        }
        return albumView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let song = album.songs[indexPath.item]
        player.playSong(song)
        player.songsList = Array(album.songs)
    }
}

extension AlbumVC: EditAlbumDelegate {
    
    func editedAlbum() {
        songsView.reloadData()
        editPresenter.dismiss()
        updateAlbumsView()
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
        library.removeSongFromAlbum(song) {
            self.songsView.deleteItems(at: [indexPath])
        }
    }
    
    func renameSong(_ song: Song, with name: String, at indexPath: IndexPath) {
        library.renameSong(song, with: name) {
            self.songsView.reloadItems(at: [indexPath])
        }
    }
    
    func removeSong(_ song: Song, at indexPath: IndexPath) {
        let checkPlaylists = !song.playlists.isEmpty
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
        library.removeAlbum(album) {
            self.updateAlbumsView()
            self.navigationController?.popViewController(animated: true)
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

