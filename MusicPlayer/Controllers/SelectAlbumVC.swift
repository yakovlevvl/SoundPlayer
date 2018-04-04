//
//  SelectAlbumVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 04.04.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SelectAlbumVC: UIViewController {
    
    var song: Song!
    
    private let library = Library.main
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Select Album"
        topBar.includeRightButton = false
        topBar.setLeftButtonImage(UIImage(named: "CloseIcon"))
        return topBar
    }()
    
    private let albumsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 18
        layout.sectionInset.left = 20
        layout.sectionInset.right = 20
        layout.minimumLineSpacing = 17
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: (screenWidth - 20*3)/2, height: 184)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: albumsView.bounds)
        view.text = "No albums"
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white

        view.addSubview(albumsView)
        view.addSubview(topBar)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapCloseButton()
        }

        albumsView.delegate = self
        albumsView.dataSource = self
        albumsView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.reuseId)
        
        layoutViews()
    }

    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 76)
        
        albumsView.frame = view.bounds
        albumsView.contentInset.top = topBar.frame.height + 2
        albumsView.scrollIndicatorInsets.top = albumsView.contentInset.top
    }
    
    private func tapCloseButton() {
        dismiss(animated: true)
    }
}

extension SelectAlbumVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = library.albumsCount
        albumsView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

extension SelectAlbumVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        library.album(for: indexPath.item) { album in
            self.library.addSong(self.song, to: album)
            self.dismiss(animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            topBar.makeOpaque(with: Colors.clearWhite)
        } else {
            topBar.makeTransparent()
        }
    }
}
