//
//  NewAlbumVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 13.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class NewPlaylistVC: UIViewController {
    
    var addedSongs = [Song]()
    
    fileprivate var playlistTitle = ""
    
    fileprivate var artworkImage: UIImage?
    
    weak var delegate: NewPlaylistDelegate?
    
    fileprivate let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "New Playlist"
        topBar.setRightButtonFontSize(20)
        topBar.setRightButtonTitle("Done")
        topBar.setRightButtonTitleColor(Colors.red)
        topBar.setLeftButtonImage(UIImage(named: "CloseIcon"))
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
    
    fileprivate let transitionManager = VerticalTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        view.insertSubview(songsView, at: 0)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapCloseButton()
        }
        topBar.onRightButtonTapped = { [unowned self] in
            self.tapDoneButton()
        }
        
        songsView.delegate = self
        songsView.dataSource = self
        songsView.register(NewAlbumSongCell.self, forCellWithReuseIdentifier: NewAlbumSongCell.reuseId)
        registerSupplementaryViewClass()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        songsView.addGestureRecognizer(longPressGesture)
        
        setupKeyboardObserver()
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 82)
        
        songsView.frame = view.bounds
        songsView.contentInset.top = topBar.frame.height
        songsView.scrollIndicatorInsets.top = songsView.contentInset.top
        
        let layout = songsView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: songsView.frame.width, height: 226)
    }
    
    fileprivate func registerSupplementaryViewClass() {
        songsView.register(NewPlaylistView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NewPlaylistView.reuseId)
    }
    
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue!
        if frame.origin.y >= view.frame.height {
            songsView.contentInset.bottom = 0
            songsView.scrollIndicatorInsets.bottom = 0
        } else {
            songsView.contentInset.bottom = frame.height
            songsView.scrollIndicatorInsets.bottom = frame.height
        }
    }
    
    @objc private func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began :
            let point = gesture.location(in: songsView)
            guard let indexPath = songsView.indexPathForItem(at: point) else { break }
            songsView.beginInteractiveMovementForItem(at: indexPath)
        case .changed :
            let point = gesture.location(in: songsView)
            songsView.updateInteractiveMovementTargetPosition(point)
        case .ended :
            songsView.endInteractiveMovement()
        default :
            songsView.cancelInteractiveMovement()
        }
    }
    
    fileprivate func decideDoneButtonState() {
        if !playlistTitle.trimmingCharacters(in: .whitespaces).isEmpty,
            !addedSongs.isEmpty {
            topBar.enableRightButton()
        } else {
            topBar.disableRightButton()
        }
    }
    
    fileprivate func tapCloseButton() {
        dismiss(animated: true)
    }
    
    fileprivate func tapDoneButton() {
        Library.main.addPlaylist(with: playlistTitle, songs: addedSongs, artwork: artworkImage)
        dismiss(animated: true)
        delegate?.addedNewPlaylist()
    }
    
    func didTapAddMusicButton() {
        let addSongsVC = PlaylistAddSongsVC()
        addSongsVC.delegate = self
        addSongsVC.addedSongs = addedSongs
        addSongsVC.transitioningDelegate = transitionManager
        present(addSongsVC, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NewPlaylistVC: NewAlbumSongCellDelegate {
    
    func tapRemoveButton(_ cell: NewAlbumSongCell) {
        guard let indexPath = songsView.indexPath(for: cell) else { return }
        addedSongs.remove(at: indexPath.item)
        songsView.deleteItems(at: [indexPath])
    }
}

extension NewPlaylistVC: NewPlaylistViewDelegate {
    
    func titleFieldChangedText(_ text: String) {
        playlistTitle = text
        decideDoneButtonState()
    }
    
    func didTapAddArtworkButton() {
        if artworkImage == nil {
            showAddArtworkVC()
        } else {
            showArtworkActions()
        }
    }
    
    private func showAddArtworkVC() {
        let addArtworkVC = AddArtworkVC()
        addArtworkVC.delegate = self
        addArtworkVC.transitioningDelegate = transitionManager
        present(addArtworkVC, animated: true)
    }
    
    private func showArtworkActions() {
        let actionSheet = RoundActionSheet()
        let chooseAction = Action(title: "Choose Artwork", type: .normal) {
            self.showAddArtworkVC()
        }
        let removeAction = Action(title: "Remove Artwork", type: .destructive) { 
            self.artworkImage = nil
            self.songsView.reloadData()
        }
        actionSheet.addAction(chooseAction)
        actionSheet.addAction(removeAction)
        actionSheet.present()
    }
}

extension NewPlaylistVC: AddSongsDelegate {
    
    func didSelectSongs(_ songs: [Song]) {
        addedSongs = songs
        songsView.reloadData()
    }
}

extension NewPlaylistVC: AddArtworkDelegate {
    
    func didSelectArtwork(_ image: UIImage) {
        artworkImage = image
        songsView.reloadData()
    }
}

extension NewPlaylistVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        decideDoneButtonState()
        return addedSongs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewAlbumSongCell.reuseId, for: indexPath) as! NewAlbumSongCell
        cell.delegate = self
        cell.setup(for: addedSongs[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let playlistView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NewPlaylistView.reuseId, for: indexPath) as! NewPlaylistView
        playlistView.delegate = self
        playlistView.setupTitle(playlistTitle)
        playlistView.setupArtworkImage(artworkImage)
        return playlistView
    }
}

extension NewPlaylistVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let song = addedSongs[sourceIndexPath.item]
        addedSongs.remove(at: sourceIndexPath.item)
        addedSongs.insert(song, at: destinationIndexPath.item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            topBar.makeOpaque(with: Colors.clearWhite)
        } else {
            topBar.makeTransparent()
        }
    }
}

protocol NewPlaylistDelegate: class {
    
    func addedNewPlaylist()
}


class NewAlbumVC: NewPlaylistVC {
    
    fileprivate var albumArtist = ""
    
    weak var newAlbumDelegate: NewAlbumDelegate?
    
    override func setupViews() {
        super.setupViews()
        topBar.title = "New Album"
    }
    
    override func registerSupplementaryViewClass() {
        songsView.register(NewAlbumView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NewAlbumView.reuseId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let albumView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NewAlbumView.reuseId, for: indexPath) as! NewAlbumView
        albumView.delegate = self
        albumView.setupTitle(playlistTitle)
        albumView.setupArtist(albumArtist)
        albumView.setupArtworkImage(artworkImage)
        return albumView
    }

    override func tapDoneButton() {
        Library.main.addAlbum(with: playlistTitle,
            artist: albumArtist, songs: addedSongs, artwork: artworkImage)
        dismiss(animated: true)
        newAlbumDelegate?.addedNewAlbum()
    }
    
    override func decideDoneButtonState() {
        if !playlistTitle.trimmingCharacters(in: .whitespaces).isEmpty,
            !albumArtist.trimmingCharacters(in: .whitespaces).isEmpty,
            !addedSongs.isEmpty {
            topBar.enableRightButton()
        } else {
            topBar.disableRightButton()
        }
    }
    
    override func didTapAddMusicButton() {
        let addSongsVC = AlbumAddSongsVC()
        addSongsVC.delegate = self
        addSongsVC.addedSongs = addedSongs
        addSongsVC.transitioningDelegate = transitionManager
        present(addSongsVC, animated: true)
    }
}

extension NewAlbumVC: NewAlbumViewDelegate {
    
    func artistFieldChangedText(_ text: String) {
        albumArtist = text
        decideDoneButtonState()
    }
}

protocol NewAlbumDelegate: class {
    
    func addedNewAlbum()
}


final class EditPlaylistVC: NewPlaylistVC {
    
    var playlist: Playlist!
    
    weak var editPlaylistDelegate: EditPlaylistDelegate?
    
    override func setupViews() {
        super.setupViews()
        playlistTitle = playlist.title
        artworkImage = playlist.artwork
        topBar.title = "Edit Playlist"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addedSongs = addedSongs.filter { !$0.isInvalidated }
        songsView.reloadData()
    }
    
    override func didTapAddMusicButton() {
        let addSongsVC = PlaylistAddSongsVC()
        addSongsVC.playlist = playlist
        addSongsVC.delegate = self
        addSongsVC.addedSongs = addedSongs
        addSongsVC.transitioningDelegate = transitionManager
        present(addSongsVC, animated: true)
    }
    
    override func tapDoneButton() {
        Library.main.editPlaylist(playlist, with: playlistTitle,
            songs: addedSongs, artwork: artworkImage)
        editPlaylistDelegate?.editedPlaylist()
    }
    
    override func tapCloseButton() {
        editPlaylistDelegate?.tappedCloseButton()
    }
}

protocol EditPlaylistDelegate: class {
    
    func editedPlaylist()
    func tappedCloseButton()
}


final class EditAlbumVC: NewAlbumVC {
    
    var album: Album!
    
    weak var editAlbumDelegate: EditAlbumDelegate?
    
    override func setupViews() {
        super.setupViews()
        playlistTitle = album.title
        albumArtist = album.artist
        artworkImage = album.artwork
        topBar.title = "Edit Album"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addedSongs = addedSongs.filter { !$0.isInvalidated }
        songsView.reloadData()
    }
    
    override func didTapAddMusicButton() {
        let addSongsVC = AlbumAddSongsVC()
        addSongsVC.album = album
        addSongsVC.delegate = self
        addSongsVC.addedSongs = addedSongs
        addSongsVC.transitioningDelegate = transitionManager
        present(addSongsVC, animated: true)
    }
    
    override func tapDoneButton() {
        Library.main.editAlbum(album, with: playlistTitle,
            artist: albumArtist, songs: addedSongs, artwork: artworkImage)
        editAlbumDelegate?.editedAlbum()
    }
    
    override func tapCloseButton() {
        editAlbumDelegate?.tappedCloseButton()
    }
}

protocol EditAlbumDelegate: class {
    
    func editedAlbum()
    func tappedCloseButton()
}

