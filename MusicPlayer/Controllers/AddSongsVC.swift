//
//  AddSongsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 17.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class AddSongsVC: UIViewController {
    
    var album: Album?
    
    var addedSongs = [Song]()
    
    private var songs = [(Song, isAdded: Bool)]()
    
    weak var delegate: AddSongsDelegate?
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Add Songs"
        topBar.setRightButtonFontSize(20)
        topBar.setRightButtonTitle("Done")
        topBar.setRightButtonTitleColor(Colors.red)
        topBar.setLeftButtonImage(UIImage(named: "CloseIcon"))
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
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: songsView.bounds)
        view.text = "No songs"
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapCloseButton()
        }
        topBar.onRightButtonTapped = { [unowned self] in
            self.tapDoneButton()
        }
        
        songsView.delegate = self
        songsView.dataSource = self
        songsView.register(AddSongCell.self, forCellWithReuseIdentifier: AddSongCell.reuseId)
        view.insertSubview(songsView, at: 0)
        
        layoutViews()
        
        fetchSongs()
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 82)
        
        songsView.frame = view.bounds
        songsView.contentInset.top = topBar.frame.height + 2
        songsView.scrollIndicatorInsets.top = songsView.contentInset.top
    }
    
    private func fetchSongs() {
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
    
    private func didSelectSong(at indexPath: IndexPath) {
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
    
    private func checkAddedSongsCount() {
        if addedSongs.count == 0 {
            topBar.disableRightButton()
        } else {
            topBar.enableRightButton()
        }
    }

}

extension AddSongsVC {
    
    func tapCloseButton() {
        dismiss(animated: true)
    }
    
    func tapDoneButton() {
        dismiss(animated: true)
        delegate?.didSelectSongs(addedSongs)
    }
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
        checkAddedSongsCount()
        let count = songs.count
        songsView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddSongCell.reuseId, for: indexPath) as! AddSongCell
        cell.delegate = self
        let song = songs[indexPath.item]
        cell.setup(for: song.0, isAdded: song.isAdded)
        return cell
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

protocol AddSongsDelegate: class {
    
    func didSelectSongs(_ songs: [Song])
}
