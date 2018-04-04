//
//  PlaylistsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 10.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class PlaylistsVC: UIViewController {
    
    private let player = Player.main
    
    private let library = Library.main
    
    weak var delegate: PlaylistsDelegate?
    
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
        button.titleLabel!.font = UIFont(name: Fonts.general, size: 20)
        button.setTitleColor(UIColor(hex: "D0021B"), for: .normal)
        return button
    }()
    
    private let playlistsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 10
        layout.sectionInset.left = 20
        layout.sectionInset.right = 20
        layout.minimumLineSpacing = 17
        layout.minimumInteritemSpacing = 20
        let itemWidth = (screenWidth - 20*3)/2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 54)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: playlistsView.bounds)
        view.text = "Added playlists will appear here."
        view.icon = UIImage(named: "MusicIcon")!
        return view
    }()
    
    private let transitionManager = VerticalTransitionManager()
    
    private let topInset: CGFloat = 70
    
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
        
        view.addSubview(playlistsView)
        view.addSubview(sortButton)
        view.addSubview(addButton)
        
        playlistsView.delegate = self
        playlistsView.dataSource = self
        playlistsView.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.reuseId)
        
        addButton.addTarget(self, action: #selector(tapAddButton), for: .touchUpInside)
        sortButton.addTarget(self, action: #selector(tapSortButton), for: .touchUpInside)
    }
    
    private func layoutViews() {
        addButton.center.y = topInset/2 - 2
        let value = ((view.frame.width - 50)/3)/2
        addButton.frame.origin.x = view.frame.width - addButton.frame.width/2 - 25 - value
        
        sortButton.center.y = topInset/2 - 2
        sortButton.center.x = 25 + value
        
        playlistsView.frame.origin.x = 0
        playlistsView.frame.origin.y = topInset/2
        playlistsView.frame.size = CGSize(width: view.frame.width, height: view.frame.height - playlistsView.frame.origin.y)
        playlistsView.contentInset.top = topInset/2
        playlistsView.scrollIndicatorInsets.top = topInset/2
    }
    
    @objc private func tapAddButton() {
        let newAlbumVC = NewAlbumVC()
        newAlbumVC.delegate = self
        newAlbumVC.transitioningDelegate = transitionManager
        present(newAlbumVC, animated: true)
    }
    
    @objc private func tapSortButton() {
        let actionSheet = ActionSheet()
        actionSheet.cornerRadius = 12
        actionSheet.corners = [.topLeft, .topRight]
        actionSheet.actionCellHeight = Screen.is4inch ? 68 : 70
        actionSheet.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let titleAction = Action(title: "Title", type: .normal) { _ in
            self.setupSortMethod(.title)
        }
        let artistAction = Action(title: "Artist", type: .normal) { _ in
            self.setupSortMethod(.artist)
        }
        let dateAction = Action(title: "Creation Date", type: .normal) { _ in
            self.setupSortMethod(.creationDate)
        }
        actionSheet.addAction(titleAction)
        actionSheet.addAction(artistAction)
        actionSheet.addAction(dateAction)
        actionSheet.addAction(cancelAction)
        actionSheet.present()
    }
    
    private func setupSortMethod(_ method: Library.SortMethod) {
        if library.albumsSortMethod == method { return }
        library.albumsSortMethod = method
        updateAlbumsView()
    }
    
    func updateAlbumsView() {
        playlistsView.reloadSections(IndexSet(integer: 0))
    }
}

extension PlaylistsVC: NewAlbumDelegate {
    
    func addedNewAlbum() {
        updateAlbumsView()
    }
}

extension PlaylistsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = library.playlistsCount
        sortButton.alpha = count == 0 ? 0 : 1
        playlistsView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

extension PlaylistsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        library.album(for: indexPath.item) { album in
            self.delegate?.didSelectAlbum(album)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if playlistsView.contentOffset.y > -playlistsView.contentInset.top/2 {
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

protocol PlaylistsDelegate: class {
    
    func didSelectAlbum(_ album: Album)
}
