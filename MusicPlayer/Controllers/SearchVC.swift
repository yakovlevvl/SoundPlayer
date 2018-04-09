//
//  SearchVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 06.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum SearchTitles: String {
    
    case songs = "Songs"
    case albums = "Albums"
    case playlists = "Playlists"
}

protocol SearchDelegate: class {
    
    func tapCancelButton()
    func didSelectSong(_ song: Song)
    func didSelectAlbum(_ album: Album)
    func didSelectPlaylist(_ playlist: Playlist)
}

final class SearchVC: UIViewController {
    
    weak var delegate: SearchDelegate?
    
    private let library = Library.main
    
    private var songsOutput = [Song]()
    
    private var albumsOutput = [Album]()
    
    private var playlistsOutput = [Playlist]()
    
    private let titles: [SearchTitles] = [.songs, .albums, .playlists]
    
    let transitionManager = VerticalTransitionManager()
    
    private let searchBar = LibrarySearchBar()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 14
        layout.minimumLineSpacing = 14
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAllSections()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        view.insertSubview(collectionView, at: 0)
        
        searchBar.onCancelButtonTapped = { [unowned self] in
            self.tapCancelButton()
        }
        searchBar.onSearchFieldChangedText = { [unowned self] in
            self.searchTextChanged()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SongCell.self, forCellWithReuseIdentifier: SongCell.reuseId)
        collectionView.register(AlbumMiniCell.self, forCellWithReuseIdentifier: AlbumMiniCell.reuseId)
        collectionView.register(PlaylistMiniCell.self, forCellWithReuseIdentifier: PlaylistMiniCell.reuseId)
        collectionView.register(SearchTitleHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SearchTitleHeader.reuseId)

        setupKeyboardObserver()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.searchBar.showKeyboard()
        }
    }
    
    private func layoutViews() {
        searchBar.frame.origin = .zero
        searchBar.frame.size = CGSize(width: view.frame.width, height: 80)
        
        collectionView.frame = view.bounds
        collectionView.contentInset.top = searchBar.frame.height - 10
        collectionView.scrollIndicatorInsets.top = searchBar.frame.height
    }
    
    private func searchTextChanged() {
        updateSongsSection()
        updateAlbumsSection()
        updatePlaylistsSection()
    }
    
    private func updateAllSections() {
        updateSongsOutput(searchBar.searchText) {
            self.collectionView.reloadData()
        }
        updateAlbumsOutput(searchBar.searchText) {
            self.collectionView.reloadData()
        }
        updatePlaylistsOutput(searchBar.searchText) {
            self.collectionView.reloadData()
        }
    }
    
    private func updateSongsSection() {
        updateSongsOutput(searchBar.searchText) {
            let section = self.titles.index(of: .songs)!
            self.collectionView.reloadSections(IndexSet(integer: section))
        }
    }
    
    private func updateAlbumsSection() {
        updateAlbumsOutput(searchBar.searchText) {
            let section = self.titles.index(of: .albums)!
            self.collectionView.reloadSections(IndexSet(integer: section))
        }
    }
    
    private func updatePlaylistsSection() {
        updatePlaylistsOutput(searchBar.searchText) {
            let section = self.titles.index(of: .playlists)!
            self.collectionView.reloadSections(IndexSet(integer: section))
        }
    }
    
    private func updateSongsOutput(_ searchText: String, completion: @escaping () -> ()) {
        library.songsWithTitleStarted(with: searchText) { songs in
            self.songsOutput = songs
            completion()
        }
    }
    
    private func updateAlbumsOutput(_ searchText: String, completion: @escaping () -> ()) {
        library.albumsWithTitleStarted(with: searchText) { albums in
            self.albumsOutput = albums
            completion()
        }
    }
    
    private func updatePlaylistsOutput(_ searchText: String, completion: @escaping () -> ()) {
        library.playlistsWithTitleStarted(with: searchText) { playlists in
            self.playlistsOutput = playlists
            completion()
        }
    }
    
    private func tapCancelButton() {
        searchBar.hideKeyboard()
        delegate?.tapCancelButton()
    }
    
    private func updateSongsView() {
        (parent as! LibraryVC).updateSongsView()
    }
    
    private func updateAlbumsView() {
        (parent as! LibraryVC).updateAlbumsView()
    }
    
    private func updatePlaylistsView() {
        (parent as! LibraryVC).updatePlaylistsView()
    }
    
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue!
        if frame.origin.y >= view.frame.height {
            collectionView.contentInset.bottom = 0
            collectionView.scrollIndicatorInsets.bottom = 0
        } else {
            collectionView.contentInset.bottom = view.frame.height - frame.origin.y
            collectionView.scrollIndicatorInsets.bottom = collectionView.contentInset.bottom
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SearchVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch titles[section] {
        case .songs : return songsOutput.count
        case .albums : return albumsOutput.count
        case .playlists : return playlistsOutput.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch titles[indexPath.section] {
            
        case .songs :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.reuseId, for: indexPath) as! SongCell
            cell.delegate = self
            cell.setup(for: songsOutput[indexPath.item])
            return cell
            
        case .albums :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumMiniCell.reuseId, for: indexPath) as! AlbumMiniCell
            let album = albumsOutput[indexPath.item]
            cell.setTitle(album.title)
            cell.setArtist(album.artist)
            cell.tag += 1
            let tag = cell.tag
            album.getArtworkAsync { artwork in
                if cell.tag == tag {
                    cell.setArtwork(artwork)
                }
            }
            return cell
            
        case .playlists :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistMiniCell.reuseId, for: indexPath) as! PlaylistMiniCell
            let playlist = playlistsOutput[indexPath.item]
            cell.setTitle(playlist.title)
            cell.tag += 1
            let tag = cell.tag
            playlist.getArtworkAsync { artwork in
                if cell.tag == tag {
                    cell.setArtwork(artwork)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SearchTitleHeader.reuseId, for: indexPath) as! SearchTitleHeader
        view.setupTitle(titles[indexPath.section].rawValue)
        return view
    }
}

extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch titles[indexPath.section] {
        case .songs :
            let song = songsOutput[indexPath.item]
            delegate?.didSelectSong(song)
        case .albums :
            let album = albumsOutput[indexPath.item]
            delegate?.didSelectAlbum(album)
        case .playlists :
            let playlist = playlistsOutput[indexPath.item]
            delegate?.didSelectPlaylist(playlist)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: view.frame.width, height: 70)
        switch titles[section] {
        case .songs : return songsOutput.isEmpty ? .zero : size
        case .albums : return albumsOutput.isEmpty ? .zero : size
        case .playlists : return playlistsOutput.isEmpty ? .zero : size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch titles[indexPath.section] {
        case .songs : return CGSize(width: view.frame.width - 32, height: 70)
        default : return CGSize(width: view.frame.width - 32, height: 104)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            searchBar.makeOpaque(with: Colors.clearWhite)
        } else {
            searchBar.makeTransparent()
        }
    }
}

extension SearchVC: SongCellDelegate {
    
    func tapMoreButton(_ cell: SongCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let song = songsOutput[indexPath.item]
        showActions(for: song, at: indexPath)
        searchBar.hideKeyboard()
    }
}

extension SearchVC: SongActions {
    
    func renameSong(_ song: Song, with name: String, at indexPath: IndexPath) {
        library.renameSong(song, with: name) {
            self.updateSongsSection()
            self.updateSongsView()
        }
    }
    
    func removeSong(_ song: Song, at indexPath: IndexPath) {
        if let album = song.album, album.songs.count == 1 {
            let reloadAlbums = albumsOutput.contains(album)
            library.removeAlbum(album) {
                self.updateAlbumsView()
                if reloadAlbums {
                    self.updateAlbumsSection()
                }
            }
        }
        let checkPlaylists = !song.playlists.isEmpty
        library.removeSong(song) {
            self.updateSongsSection()
            self.updateSongsView()
            if checkPlaylists {
                self.library.removeEmptyPlaylists { removed in
                    if removed {
                        self.updatePlaylistsView()
                        self.updatePlaylistsSection()
                    }
                }
            }
        }
    }
}
