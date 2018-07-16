//
//  SettingsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 08.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SettingsVC: UIViewController {
    
    private let topBar = SettingsTopBar()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 16
        layout.minimumLineSpacing = 14
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private let headerId = "headerId"
    
    private let settings = [["Search", "Browser", "Passcode Lock"], ["Rate app", "Tell a friend", "Send feedback"]]
    
    /// Settings
    // ~ Tell a friend
    // ~ Send feedback
    // ~ Search (Spotlight)
    // ~ Browser (Download files via cellular or wi-fi)
    // ~ Passcode
    // ~ Clear History
    // ~ Clear Cookies
    // ~ Disk space
    
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.reuseId)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
    
        setupPlayerBarObserver()
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 90)
        
        collectionView.frame = view.bounds
        collectionView.contentInset.top = topBar.frame.height + 18
        collectionView.scrollIndicatorInsets.top = collectionView.contentInset.top
    }
    
    deinit {
        removePlayerBarObserver()
    }
}

extension SettingsVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.reuseId, for: indexPath) as! SettingCell
        cell.setupTitle(settings[indexPath.section][indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath)
        return view
    }
}

extension SettingsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.item {
            case 0: navigationController?.pushViewController(SearchSettingsVC(), animated: true)
                
            default:
                break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth - 32, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 { return .zero}
        return CGSize(width: view.frame.width, height: 24)
    }
}

extension SettingsVC: PlayerBarObservable {
    
    func playerBarAppeared() {
        collectionView.contentInset.bottom = PlayerBarProperties.barHeight
        collectionView.scrollIndicatorInsets.bottom = PlayerBarProperties.barHeight
    }
    
    func playerBarDisappeared() {
        collectionView.contentInset.bottom = 0
        collectionView.scrollIndicatorInsets.bottom = 0
    }
}
