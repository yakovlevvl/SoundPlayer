//
//  BrowserHistoryVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 04.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BrowserHistoryVC: UIViewController {
    
    var historyManager: BrowserHistoryManager!
    
    weak var delegate: BrowserHistoryDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recently visited"
        label.frame.size = CGSize(width: 160, height: 26)
        label.font = UIFont(name: Fonts.general, size: 20)
        return label
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setTitle("Clear", for: .normal)
        button.titleLabel!.font = UIFont(name: Fonts.general, size: 20)
        button.setTitleColor(UIColor(hex: "4A90E2"), for: .normal)
        return button
    }()
    
    private let itemsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 2
        layout.sectionInset.top = 2
        layout.minimumLineSpacing = 2
        layout.itemSize = CGSize(width: screenWidth, height: 56)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.alpha = 0
        view.backgroundColor = .white
        
        view.addSubview(itemsView)
        view.addSubview(titleLabel)
        view.addSubview(clearButton)
        
        itemsView.delegate = self
        itemsView.dataSource = self
        itemsView.register(BrowserHistoryItemCell.self, forCellWithReuseIdentifier: BrowserHistoryItemCell.reuseId)
        
        clearButton.addTarget(self, action: #selector(tapClearButton), for: .touchUpInside)
    }
    
    private func layoutViews() {
        titleLabel.frame.origin = CGPoint(x: 22, y: 28)
        clearButton.center.y = titleLabel.center.y
        clearButton.frame.origin.x = view.frame.width - clearButton.frame.width - 22
        
        itemsView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.maxY + 16)
        itemsView.frame.size = CGSize(width: view.frame.width, height: view.frame.height - itemsView.frame.origin.y)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
        print("viewWillLayoutSubviews")
    }
    
    private func hideViews() {
        UIView.animate(0.18) {
            self.view.alpha = 0
        }
    }
    
    private func showViews() {
        UIView.animate(0.18) {
            self.view.alpha = 1
        }
    }
    
    @objc private func tapClearButton() {
        historyManager.clearHistory {
            self.hideViews()
        }
    }
}

extension BrowserHistoryVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = historyManager.itemsCount
        if count > 0 {
            showViews()
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowserHistoryItemCell.reuseId, for: indexPath) as! BrowserHistoryItemCell
        cell.tag += 1
        let tag = cell.tag
        historyManager.item(for: indexPath.item) { item in
            if cell.tag == tag {
                cell.setup(for: item)
            }
        }
        return cell
    }
}

extension BrowserHistoryVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        historyManager.item(for: indexPath.item) { item in
            self.delegate?.didSelectHistoryItem(with: item.url)
        }
    }
}

protocol BrowserHistoryDelegate: class {
    
    func didSelectHistoryItem(with url: URL)
}
