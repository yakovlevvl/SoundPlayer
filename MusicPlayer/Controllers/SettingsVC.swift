//
//  SettingsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 08.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class SettingsVC: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Library"
        label.frame.size = CGSize(width: 120, height: 34)
        label.font = UIFont(name: Fonts.general, size: 30)
        return label
    }()
    
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
        
        view.addSubview(titleLabel)
    }
    
    private func layoutViews() {
        
//        searchBar.frame.origin = .zero
//        searchBar.frame.size = CGSize(width: view.frame.width, height: 80)
//
//        collectionView.frame = view.bounds
//        collectionView.contentInset.top = searchBar.frame.height - 10
//        collectionView.scrollIndicatorInsets.top = searchBar.frame.height
    }
}
