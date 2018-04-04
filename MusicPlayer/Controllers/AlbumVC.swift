//
//  AlbumVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 19.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class AlbumVC: UIViewController {
    
    var album: Album!
    
    private let player = Player.main
    
    private let library = Library.main
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Album"
        topBar.setRightButtonFontSize(20)
        topBar.setRightButtonTitle("Edit")
        topBar.setRightButtonTitleColor(Colors.red)
        topBar.setLeftButtonImage(UIImage(named: "BackIcon"))
        return topBar
    }()
    
    private let songsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 16
        layout.minimumLineSpacing = 14
        layout.itemSize = CGSize(width: screenWidth - 32, height: 70)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var editAlbumPresenter: FadeChildControllerPresenter!
    
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
        songsView.register(AlbumView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AlbumView.reuseId)
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
}

extension AlbumVC {
    
    private func tapEditButton() {
        let editAlbumVC = EditAlbumVC()
        editAlbumVC.album = album
        editAlbumVC.editAlbumDelegate = self
        editAlbumVC.addedSongs = Array(album.songs)
        editAlbumPresenter = FadeChildControllerPresenter(parentController: self)
        editAlbumPresenter.present(editAlbumVC)
    }
    
    private func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension AlbumVC: EditAlbumDelegate {
    
    func editedAlbum() {
        songsView.reloadData()
        editAlbumPresenter.dismiss()
        updateAlbumsView()
    }
    
    func tappedCloseButton() {
        editAlbumPresenter.dismiss()
    }
    
    private func updateAlbumsView() {
        let libraryVC = navigationController!.viewControllers.first as! LibraryVC
        libraryVC.updateAlbumsView()
    }
}

extension AlbumVC: SongCellDelegate {
    
    func tapMoreButton(_ cell: SongCell) {
        guard let indexPath = songsView.indexPath(for: cell) else { return }
        let song = album.songs[indexPath.item]
        showActions(for: song, at: indexPath)
    }
    
    private func showActions(for song: Song, at indexPath: IndexPath) {
        let actionSheet = ActionSheet()
        actionSheet.cornerRadius = 12
        actionSheet.corners = [.topLeft, .topRight]
        actionSheet.actionCellHeight = Screen.is4inch ? 68 : 70
        actionSheet.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let albumRemoveAction = Action(title: "Delete from Album", type: .normal) { _ in
            self.removeSongFromAlbum(song, at: indexPath)
        }
        let renameAction = Action(title: "Rename", type: .normal) { _ in
            self.showAlertViewForRenameSong(song, at: indexPath)
        }
        let addToPlaylistAction = Action(title: "Add to Playlist", type: .normal) { _ in
            
        }
        let removeAction = Action(title: "Delete from Library", type: .destructive) { _ in
            self.removeSong(song, at: indexPath)
        }
        actionSheet.addAction(renameAction)
        actionSheet.addAction(addToPlaylistAction)
        if album.songs.count > 1 {
            actionSheet.addAction(albumRemoveAction)
            actionSheet.addAction(removeAction)
        }
        actionSheet.addAction(cancelAction)
        actionSheet.present()
    }

    private func renameSong(_ song: Song, with name: String, at indexPath: IndexPath) {
        library.renameSong(song, with: name) {
            self.songsView.reloadItems(at: [indexPath])
        }
    }
    
    private func removeSong(_ song: Song, at indexPath: IndexPath) {
        library.removeSong(song) {
            self.songsView.deleteItems(at: [indexPath])
        }
    }
    
    private func removeSongFromAlbum(_ song: Song, at indexPath: IndexPath) {
        library.removeSongFromAlbum(song) {
            self.songsView.deleteItems(at: [indexPath])
        }
    }
    
    private func showAlertViewForRenameSong(_ song: Song, at indexPath: IndexPath) {
        let alertVC = AlertController(message: "Rename Song")
        alertVC.includeTextField = true
        alertVC.allowEmptyTextField = false
        alertVC.showClearButton = true
        alertVC.textFieldPlaceholder = "Name"
        alertVC.textFieldText = song.title
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let renameAction = Action(title: "Save", type: .normal) { _ in
            let songName = alertVC.textFieldText!
            self.renameSong(song, with: songName, at: indexPath)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(renameAction)
        alertVC.present()
    }
}

extension AlbumVC: AlbumViewDelegate {
    
    func tapMoreButton() {
        let actionSheet = ActionSheet()
        actionSheet.cornerRadius = 12
        actionSheet.corners = [.topLeft, .topRight]
        actionSheet.actionCellHeight = Screen.is4inch ? 68 : 70
        actionSheet.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let removeAction = Action(title: "Delete", type: .destructive) { _ in
            self.removeAlbum()
        }
        let addToPlaylistAction = Action(title: "Add to Playlist", type: .normal) { _ in
            
        }
        actionSheet.addAction(addToPlaylistAction)
        actionSheet.addAction(removeAction)
        actionSheet.addAction(cancelAction)
        actionSheet.present()
    }
    
    private func removeAlbum() {
        library.removeAlbum(album) {
            self.updateAlbumsView()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tapPlayButton() {
        
    }
    
    func tapShuffleButton() {
        
    }
}

extension AlbumVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.reuseId, for: indexPath) as! SongCell
        cell.delegate = self
        cell.setup(for: album.songs[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let albumView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AlbumView.reuseId, for: indexPath) as! AlbumView
        albumView.delegate = self
        albumView.setupTitle(album.title)
        albumView.setupArtist(album.artist)
        album.getArtworkAsync { artwork in
            albumView.setupArtworkImage(artwork)
        }
        return albumView
    }
}

extension AlbumVC: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let topInset = scrollView.contentInset.top
        if yOffset > -topInset {
            topBar.makeOpaque(with: Colors.clearWhite)
        } else {
            topBar.makeTransparent()
        }
        if yOffset > -topInset + 32 {
            topBar.title = album.title
            //topBar.showTitle()
        } else {
            topBar.title = "Album"
            //topBar.hideTitle()
        }
    }
}
