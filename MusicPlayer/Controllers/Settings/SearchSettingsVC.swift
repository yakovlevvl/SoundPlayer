//
//  SearchSettingsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 15.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SearchSettingsVC: UIViewController {
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Search"
        topBar.setLeftButtonImage(UIImage(named: "BackIcon"))
        return topBar
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.top = 16
        layout.minimumLineSpacing = 14
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let settings: [[(setting: String, description: String)]] = [[("Enable Spotlight", "Enable Spotlight indexing for songs in your music library.")], [("Update Spotlight index", "Update Spotlight index for songs in your music library.")]]
    
    private let descriptions = ["Enable Spotlight indexing for songs in your music library.", "Update Spotlight index for songs in your music library."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Player.main.currentSong != nil ? playerBarAppeared() : playerBarDisappeared()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(topBar)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapBackButton()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.reuseId)
        collectionView.register(SettingDescriptionView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: SettingDescriptionView.reuseId)
        
        setupPlayerBarObserver()
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 76)
        
        collectionView.frame = view.bounds
        collectionView.contentInset.top = topBar.frame.height - 14
        collectionView.scrollIndicatorInsets.top = collectionView.contentInset.top
    }
    
    private func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        removePlayerBarObserver()
    }
}

extension SearchSettingsVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.reuseId, for: indexPath) as! SettingCell
        //cell.setupTitle(settings[indexPath.section][indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: SettingDescriptionView.reuseId, for: indexPath) as! SettingDescriptionView
        view.setupDescription(descriptions[indexPath.item])
        return view
    }
}

extension SearchSettingsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let textSize = descriptions[section].textSizeForMaxWidth(view.frame.width - 2*SettingDescriptionView.textHorizontalInset, font: SettingDescriptionView.font!)
        return CGSize(width: view.frame.width, height: textSize.height + 2*SettingDescriptionView.textVerticalInset)
    }
}

extension SearchSettingsVC: PlayerBarObservable {
    
    func playerBarAppeared() {
        collectionView.contentInset.bottom = PlayerBarProperties.barHeight
        collectionView.scrollIndicatorInsets.bottom = PlayerBarProperties.barHeight
    }
    
    func playerBarDisappeared() {
        collectionView.contentInset.bottom = 0
        collectionView.scrollIndicatorInsets.bottom = 0
    }
}
