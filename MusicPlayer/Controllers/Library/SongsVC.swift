//
//  SongsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 09.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SongsVC: UIViewController {
    
    private let player = Player.main
    
    private let library = Library.main
    
    private let sortButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 60, height: 46)
        button.setTitle("Sort", for: .normal)
        button.titleLabel!.font = UIFont(name: Fonts.general, size: 20)
        button.setTitleColor(UIColor(hex: "D0021B"), for: .normal)
        return button
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
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: songsView.bounds)
        view.text = "Added songs will appear here."
        view.icon = UIImage(named: "MusicIcon")!
        return view
    }()
    
    let transitionManager = VerticalTransitionManager()
    
    private let topInset: CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        songsView.reloadData()
        player.currentSong != nil ? playerBarAppeared() : playerBarDisappeared()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(songsView)
        view.addSubview(sortButton)
        
        songsView.delegate = self
        songsView.dataSource = self
        songsView.register(SongCell.self, forCellWithReuseIdentifier: SongCell.reuseId)
        
        sortButton.addTarget(self, action: #selector(tapSortButton), for: .touchUpInside)
        
        setupPlayerBarObserver()
    }
    
    private func layoutViews() {
        sortButton.center.y = topInset/2
        sortButton.frame.origin.x = view.frame.width - sortButton.frame.width - 26
        
        songsView.frame.origin.x = 0
        songsView.frame.origin.y = topInset/2
        songsView.frame.size = CGSize(width: view.frame.width, height: view.frame.height - songsView.frame.origin.y)
        songsView.contentInset.top = topInset/2
        songsView.scrollIndicatorInsets.top = topInset/2
    }
    
    @objc private func tapSortButton() {
        let actionSheet = RoundActionSheet()
        let titleAction = Action(title: "Title", type: .normal) {
            self.setupSortMethod(.title)
        }
        let dateAction = Action(title: "Creation Date", type: .normal) {
            self.setupSortMethod(.creationDate)
        }
        actionSheet.addAction(titleAction)
        actionSheet.addAction(dateAction)
        actionSheet.present()
    }
    
    private func setupSortMethod(_ method: Library.SortMethod) {
        if library.songsSortMethod == method { return }
        let updatePlayerSongsList = player.originalSongsList == library.allSongs
        library.songsSortMethod = method
        updateSongsView()
        if updatePlayerSongsList {
            player.updateSongsList(with: library.allSongs)
        }
    }
    
    func updateSongsView() {
        songsView.reloadSections(IndexSet(integer: 0))
    }
    
    private func updateAlbumsView() {
        let libraryVC = parent as! LibraryVC
        libraryVC.updateAlbumsView()
    }
    
    private func updatePlaylistsView() {
        let libraryVC = parent as! LibraryVC
        libraryVC.updatePlaylistsView()
    }
    
    private func updatePlayerBar() {
        if let baseVC = UIApplication.shared.windows.first?.rootViewController as? BaseVC {
            baseVC.updatePlayerBar()
        }
    }
    
    deinit {
        removePlayerBarObserver()
    }
    
}

extension SongsVC: SongCellDelegate {
    
    func tapMoreButton(_ cell: SongCell) {
        guard let indexPath = songsView.indexPath(for: cell) else { return }
        library.song(for: indexPath.item) { song in
            self.showActions(for: song, at: indexPath)
        }
    }
}

extension SongsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = library.songsCount
        sortButton.alpha = count == 0 ? 0 : 1
        songsView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.reuseId, for: indexPath) as! SongCell
        cell.delegate = self
        cell.tag += 1
        let tag = cell.tag
        library.song(for: indexPath.item) { song in
            if cell.tag == tag {
                cell.setup(for: song)
            }
        }
        return cell
    }
}

extension SongsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        player.playSong(with: indexPath.item, in: library.allSongs)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if songsView.contentOffset.y > -songsView.contentInset.top/2 {
            sortButton.alpha = 0
            sortButton.isHidden = true
        } else {
            sortButton.isHidden = false
            UIView.animate(0.22) {
                self.sortButton.alpha = 1
            }
        }
    }
}

extension SongsVC: SongActions {
    
    func renameSong(_ song: Song, with name: String, at indexPath: IndexPath) {
        library.renameSong(with: indexPath.item, with: name) {
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
        if let album = song.album, album.songs.count == 1 {
            if SettingsManager.spotlightIsEnabled {
                SpotlightManager.removeAlbum(album)
            }
            library.removeAlbum(album) {
                self.updateAlbumsView()
            }
        }
        if SettingsManager.spotlightIsEnabled {
            SpotlightManager.removeSong(song)
        }
        
        player.removeSongFromSongsList(song: song)
        let checkPlaylists = !song.playlists.isEmpty
    
        library.removeSong(with: indexPath.item) {
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

extension SongsVC: PlayerBarObservable {
    
    func playerBarAppeared() {
        songsView.contentInset.bottom = PlayerBarProperties.barHeight
        songsView.scrollIndicatorInsets.bottom = PlayerBarProperties.barHeight
    }
    
    func playerBarDisappeared() {
        songsView.contentInset.bottom = 0
        songsView.scrollIndicatorInsets.bottom = 0
    }
}


