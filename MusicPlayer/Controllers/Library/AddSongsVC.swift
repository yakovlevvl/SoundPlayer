//
//  AddSongsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 17.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

protocol AddSongsDelegate: class {
    
    func didSelectSongs(_ songs: [Song])
}

class AddSongsVC: UIViewController {
    
    var addedSongs = [Song]()
    
    weak var delegate: AddSongsDelegate?
    
    fileprivate let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Add Songs"
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
    
    fileprivate lazy var alertView: AlertView = {
        let view = AlertView(frame: songsView.bounds)
        view.text = "No songs"
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapCloseButton()
        }
        topBar.onRightButtonTapped = { [unowned self] in
            self.tapDoneButton()
        }
        
        registerCellClass()
        songsView.delegate = self
        songsView.dataSource = self
        view.insertSubview(songsView, at: 0)
        
        fetchSongs()
    }
    
    fileprivate func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 82)
        
        songsView.frame = view.bounds
        songsView.contentInset.top = topBar.frame.height + 2
        songsView.scrollIndicatorInsets.top = songsView.contentInset.top
    }
    
    fileprivate func checkAddedSongsCount() {
        if addedSongs.count == 0 {
            topBar.disableRightButton()
        } else {
            topBar.enableRightButton()
        }
    }
        
    private func tapCloseButton() {
        dismiss(animated: true)
    }
    
    private func tapDoneButton() {
        dismiss(animated: true)
        delegate?.didSelectSongs(addedSongs)
    }
    
    fileprivate func registerCellClass() {}
    
    fileprivate func fetchSongs() {}
    
    fileprivate func didSelectSong(at indexPath: IndexPath) {}
}

extension AddSongsVC: AddSongCellDelegate {
    
    func tapAddButton(_ cell: AddSongCell) {
        if let indexPath = songsView.indexPath(for: cell) {
            didSelectSong(at: indexPath)
        }
    }
}

extension AddSongsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension AddSongsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectSong(at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            topBar.makeOpaque(with: Colors.clearWhite)
        } else {
            topBar.makeTransparent()
        }
    }
}

final class AlbumAddSongsVC: AddSongsVC {
    
    var album: Album?
    
    private var songs = [(Song, isAdded: Bool)]()
    
    override func fetchSongs() {
        let allSongs: [Song]
        if let album = album {
            allSongs = Library.main.songsForAdding(for: album)
        } else {
            allSongs = Library.main.songsWithoutAlbum
        }
        for song in allSongs {
            let isAdded = addedSongs.contains(song)
            songs.append((song, isAdded: isAdded))
        }
        songsView.reloadData()
    }
    
    override func didSelectSong(at indexPath: IndexPath) {
        let song = songs[indexPath.item]
        songs[indexPath.item].isAdded = !song.isAdded
        if song.isAdded {
            if let index = addedSongs.index(where: { $0 == song.0 }) {
                addedSongs.remove(at: index)
            }
        } else {
            addedSongs.append(song.0)
        }
        UIView.performWithoutAnimation {
            songsView.reloadItems(at: [indexPath])
        }
    }
    
    override func registerCellClass() {
        songsView.register(AlbumAddSongCell.self, forCellWithReuseIdentifier: AlbumAddSongCell.reuseId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        checkAddedSongsCount()
        let count = songs.count
        songsView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumAddSongCell.reuseId, for: indexPath) as! AlbumAddSongCell
        cell.delegate = self
        let song = songs[indexPath.item]
        cell.setup(for: song.0, isAdded: song.isAdded)
        return cell
    }
}

final class PlaylistAddSongsVC: AddSongsVC {
    
    var playlist: Playlist?
    
    private var songs = [(Song, addedCount: Int)]()
    
    override func fetchSongs() {
        let allSongs = Library.main.allSongs
        for song in allSongs {
            var addedCount = 0
            for addedSong in addedSongs {
                if addedSong == song {
                    addedCount += 1
                }
            }
            songs.append((song, addedCount: addedCount))
        }
        songsView.reloadData()
    }
    
    override func didSelectSong(at indexPath: IndexPath) {
        let song = songs[indexPath.item]
        songs[indexPath.item].addedCount += 1
        addedSongs.append(song.0)
        UIView.performWithoutAnimation {
            songsView.reloadItems(at: [indexPath])
        }
    }

    override func registerCellClass() {
        songsView.register(PlaylistAddSongCell.self, forCellWithReuseIdentifier: PlaylistAddSongCell.reuseId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        checkAddedSongsCount()
        let count = songs.count
        songsView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistAddSongCell.reuseId, for: indexPath) as! PlaylistAddSongCell
        cell.delegate = self
        let song = songs[indexPath.item]
        cell.setup(for: song.0, addedCount: song.addedCount)
        return cell
    }
}


