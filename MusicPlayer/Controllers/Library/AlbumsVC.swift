//
//  AlbumsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 09.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class AlbumsVC: UIViewController {
    
    private let player = Player.main
    
    private let library = Library.main
    
    weak var delegate: AlbumsDelegate?
    
    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 46, height: 46)
        button.setImage(UIImage(named: "PlusIcon"), for: .normal)
        button.tintColor = UIColor(hex: "D0021B")
        button.contentMode = .center
        return button
    }()
    
    private let sortButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 60, height: 46)
        button.setTitle("Sort", for: .normal)
        button.titleLabel!.font = Fonts.sortButtonFont
        button.setTitleColor(UIColor(hex: "D0021B"), for: .normal)
        return button
    }()
    
    private let albumsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 10
        layout.sectionInset.left = 20
        layout.sectionInset.right = 20
        layout.minimumLineSpacing = 17
        layout.minimumInteritemSpacing = 20
        let itemWidth = (screenWidth - 20*3)/2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + UIProperties.AlbumCell.descriptionHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: albumsView.bounds)
        view.text = "Added albums will appear here."
        view.icon = UIImage(named: "MusicIcon")!
        return view
    }()
    
    private let transitionManager = VerticalTransitionManager()
    
    private let topInset: CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.currentSong != nil ? playerBarAppeared() : playerBarDisappeared()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(albumsView)
        view.addSubview(sortButton)
        view.addSubview(addButton)
        
        albumsView.delegate = self
        albumsView.dataSource = self
        albumsView.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.reuseId)
        
        addButton.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(tapSortButton), for: .touchUpInside)
        
        setupPlayerBarObserver()
    }
    
    private func layoutViews() {
        sortButton.center.y = topInset/2 - 2
        let value = ((view.frame.width - 50)/3)/2
        sortButton.frame.origin.x = view.frame.width - sortButton.frame.width/2 - 25 - value
        
        addButton.center.y = topInset/2 - 2
        addButton.center.x = 25 + value
        
        albumsView.frame.origin.x = 0
        albumsView.frame.origin.y = topInset/2
        albumsView.frame.size = CGSize(width: view.frame.width, height: view.frame.height - albumsView.frame.origin.y)
        albumsView.contentInset.top = topInset/2
        albumsView.scrollIndicatorInsets.top = topInset/2
    }
    
    @objc private func tapAddButton() {
        let newAlbumVC = NewAlbumVC()
        newAlbumVC.newAlbumDelegate = self
        transitionManager.cornerRadius = currentDevice == .iPhoneX ? 40 : 0
        newAlbumVC.transitioningDelegate = transitionManager
        present(newAlbumVC, animated: true)
    }
   
    @objc private func tapSortButton() {
        let actionSheet = RoundActionSheet()
        let titleAction = Action(title: "Title", type: .normal) {
            self.setupSortMethod(.title)
        }
        let artistAction = Action(title: "Artist", type: .normal) {
            self.setupSortMethod(.artist)
        }
        let dateAction = Action(title: "Creation Date", type: .normal) { 
            self.setupSortMethod(.creationDate)
        }
        actionSheet.addAction(titleAction)
        actionSheet.addAction(artistAction)
        actionSheet.addAction(dateAction)
        actionSheet.present()
    }
    
    private func setupSortMethod(_ method: Library.SortMethod) {
        if library.albumsSortMethod == method { return }
        library.albumsSortMethod = method
        updateAlbumsView()
    }
    
    func updateAlbumsView() {
        albumsView.reloadSections(IndexSet(integer: 0))
    }
    
    deinit {
        removePlayerBarObserver()
    }
}

extension AlbumsVC: NewAlbumDelegate {
    
    func addedNewAlbum() {
        updateAlbumsView()
    }
}

extension AlbumsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = library.albumsCount
        sortButton.alpha = count == 0 ? 0 : 1
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

extension AlbumsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        library.album(for: indexPath.item) { album in
            self.delegate?.didSelectAlbum(album)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if albumsView.contentOffset.y > -albumsView.contentInset.top/2 {
            addButton.alpha = 0
            addButton.isHidden = true
            sortButton.alpha = 0
            sortButton.isHidden = true
        } else {
            addButton.isHidden = false
            sortButton.isHidden = false
            UIView.animate(0.22) {
                self.addButton.alpha = 1
                self.sortButton.alpha = 1
            }
        }
    }
}

extension AlbumsVC: PlayerBarObservable {
    
    func playerBarAppeared() {
        albumsView.contentInset.bottom = UIProperties.playerBarHeight
        albumsView.scrollIndicatorInsets.bottom = UIProperties.playerBarHeight
    }
    
    func playerBarDisappeared() {
        albumsView.contentInset.bottom = 0
        albumsView.scrollIndicatorInsets.bottom = 0
    }
}

protocol AlbumsDelegate: class {

    func didSelectAlbum(_ album: Album)
}

