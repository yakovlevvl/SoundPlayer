//
//  LibraryMenuBar.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 09.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum LibraryItems: String {
    
    case songs = "Songs"
    case albums = "Albums"
    case playlists = "Playlists"
}

final class LibraryMenuBar: UIViewController {
    
    weak var delegate: LibraryMenuBarDelegate?
    
    private let items: [LibraryItems] = [.albums, .songs, .playlists]
    
    private let initialItemKey = "libraryInitialMenuItem"
    
    private var initialItem: LibraryItems {
        return getInitialItem()
    }
    
    private let markerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "D0021B")
        view.frame.size.height = 3
        view.layer.cornerRadius = 1
        return view
    }()
    
    private let buttonsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 0
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(buttonsView)
        view.addSubview(markerView)
        
        view.clipsToBounds = true

        buttonsView.delegate = self
        buttonsView.dataSource = self
        buttonsView.register(LibraryMenuItemCell.self, forCellWithReuseIdentifier: LibraryMenuItemCell.reuseId)
    }
    
    private func layoutViews() {
        buttonsView.frame = view.bounds
        
        let layout = buttonsView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.frame.width/CGFloat(items.count), height: view.frame.height)
        
        markerView.frame.size.width = layout.itemSize.width
        markerView.frame.origin.y = view.frame.height - markerView.frame.height
        
        selectInitialItem()
    }
    
    private func selectInitialItem() {
        let selectedItem = items.index(of: initialItem)!
        let indexPath = IndexPath(item: selectedItem, section: 0)
        buttonsView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        collectionView(buttonsView, didSelectItemAt: indexPath)
    }
    
    func selectItem(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        buttonsView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
        saveInitialItem(items[index])
    }
    
    func setupMarkerView(with position: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(0.4, damping: 0.95, velocity: 1) {
                self.markerView.frame.origin.x = position
            }
        } else {
            markerView.frame.origin.x = position
        }
    }
    
    private func saveInitialItem(_ item: LibraryItems) {
        UserDefaults.standard.set(item.rawValue, forKey: initialItemKey)
    }
    
    private func getInitialItem() -> LibraryItems {
        let defaults = UserDefaults.standard
        guard let rawValue = defaults.object(forKey: initialItemKey) as? String else {
            return .songs
        }
        return LibraryItems(rawValue: rawValue)!
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
}

extension LibraryMenuBar: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryMenuItemCell.reuseId, for: indexPath) as! LibraryMenuItemCell
        cell.setup(for: items[indexPath.item])
        return cell
    }
}

extension LibraryMenuBar: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let position = CGFloat(indexPath.item)*markerView.frame.width
        setupMarkerView(with: position, animated: true)
        let item = items[indexPath.item]
        saveInitialItem(item)
        delegate?.didSelectMenuItem(item)
    }
}

protocol LibraryMenuBarDelegate: class {
    
    func didSelectMenuItem(_ item: LibraryItems)
}

