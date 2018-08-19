//
//  SelectAlbumVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 04.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class SelectCompilationVC: UIViewController {
    
    fileprivate let library = Library.main
    
    fileprivate let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.includeRightButton = false
        topBar.setLeftButtonImage(UIImage(named: "CloseIcon"))
        return topBar
    }()
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 18
        layout.sectionInset.left = 20
        layout.sectionInset.right = 20
        layout.minimumLineSpacing = 17
        layout.minimumInteritemSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(topBar)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapCloseButton()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        registerCellClass()
        
        layoutViews()
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 76)
        
        if currentDevice == .iPhoneX {
            if #available(iOS 11.0, *) {
                collectionView.contentInsetAdjustmentBehavior = .never
                topBar.frame.origin.y = UIProperties.iPhoneXTopInset
            }
        }
        
        collectionView.frame.origin = topBar.frame.origin
        collectionView.frame.size.width = view.frame.width
        collectionView.frame.size.height = view.frame.height - topBar.frame.minY
        
        collectionView.contentInset.top = topBar.frame.height + 2
        collectionView.scrollIndicatorInsets.top = collectionView.contentInset.top
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
    fileprivate var cellHeight: CGFloat {
        return 100
    }
    
    fileprivate var cellWidth: CGFloat {
        return (screenWidth - 20*3)/2
    }
    
    fileprivate func registerCellClass() {}
    
    private func tapCloseButton() {
        dismiss(animated: true)
    }
}

extension SelectCompilationVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension SelectCompilationVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            topBar.makeOpaque(with: Colors.clearWhite)
        } else {
            topBar.makeTransparent()
        }
    }
}

final class SelectAlbumVC: SelectCompilationVC {
    
    var song: Song!
    
    override var cellHeight: CGFloat {
        return cellWidth + UIProperties.AlbumCell.descriptionHeight
    }

    private lazy var alertView: AlertView = {
        let view = AlertView(frame: collectionView.bounds)
        view.text = "No albums"
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        topBar.title = "Select Album"
    }
    
    override func registerCellClass() {
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.reuseId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        library.album(for: indexPath.item) { album in
            self.library.addSong(self.song, to: album)
            self.dismiss(animated: true)
            if SettingsManager.spotlightIsEnabled {
                SpotlightManager.indexSong(self.song)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = library.albumsCount
        collectionView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.reuseId, for: indexPath) as! AlbumCell
        cell.tag += 1
        let tag = cell.tag
        library.album(for: indexPath.item) { album in
            if cell.tag == tag {
                cell.setTitle(album.title)
                cell.setArtist(album.artist)
                album.getArtworkAsync { artwork in
                    if cell.tag == tag {
                        cell.setArtwork(artwork)
                    }
                }
            }
        }
        return cell
    }
}

final class SelectPlaylistVC: SelectCompilationVC {
    
    var songs: [Song]!
    
    override var cellHeight: CGFloat {
        return cellWidth + UIProperties.PlaylistCell.descriptionHeight
    }
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: collectionView.bounds)
        view.text = "No playlists"
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        topBar.title = "Select Playlist"
    }
    
    override func registerCellClass() {
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.reuseId)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        library.playlist(for: indexPath.item) { playlist in
            self.library.addSongs(self.songs, to: playlist)
            self.dismiss(animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = library.playlistsCount
        collectionView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.reuseId, for: indexPath) as! PlaylistCell
        cell.tag += 1
        let tag = cell.tag
        library.playlist(for: indexPath.item) { playlist in
            if cell.tag == tag {
                cell.setTitle(playlist.title)
                playlist.getArtworkAsync { artwork in
                    if cell.tag == tag {
                        cell.setArtwork(artwork)
                    }
                }
            }
        }
        return cell
    }
}


