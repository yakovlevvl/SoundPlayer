//
//  SettingsBaseVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 17.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class SettingsBaseVC: UIViewController {
    
    let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.setLeftButtonImage(UIImage(named: "BackIcon"))
        return topBar
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.top = 16
        layout.minimumLineSpacing = 14
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
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
    
    func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        view.insertSubview(collectionView, at: 0)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapBackButton()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.reuseId)
        collectionView.register(NavigationSettingCell.self, forCellWithReuseIdentifier: NavigationSettingCell.reuseId)
        collectionView.register(SwitchSettingCell.self, forCellWithReuseIdentifier: SwitchSettingCell.reuseId)
        collectionView.register(SettingDescriptionView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: SettingDescriptionView.reuseId)
        
        setupPlayerBarObserver()
    }
    
    func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 76)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
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

extension SettingsBaseVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
}

extension SettingsBaseVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: UIProperties.songCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            topBar.makeOpaque(with: Colors.clearWhite)
        } else {
            topBar.makeTransparent()
        }
    }
}

extension SettingsBaseVC: PlayerBarObservable {
    
    func playerBarAppeared() {
        collectionView.contentInset.bottom = UIProperties.playerBarHeight
        collectionView.scrollIndicatorInsets.bottom = UIProperties.playerBarHeight
    }
    
    func playerBarDisappeared() {
        collectionView.contentInset.bottom = 0
        collectionView.scrollIndicatorInsets.bottom = 0
    }
}
