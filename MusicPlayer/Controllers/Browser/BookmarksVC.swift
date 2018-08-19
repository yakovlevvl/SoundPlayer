//
//  BookmarksVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 01.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class BookmarksVC: UIViewController {
    
    var bookmarksManager: BookmarksManager!
    
    weak var delegate: BookmarksDelegate?
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Bookmarks"
        topBar.includeRightButton = false
        topBar.setLeftButtonImage(UIImage(named: "CloseIcon"))
        return topBar
    }()
    
    private let bookmarksView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 16
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: screenWidth - 32, height: UIProperties.bookmarkCellHeight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.darkWhite
        return collectionView
    }()
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: bookmarksView.bounds)
        view.text = "Added bookmarks will appear here."
        view.icon = UIImage(named: "BookmarksIcon")!
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = Colors.darkWhite
        
        view.addSubview(bookmarksView)
        view.addSubview(topBar)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapCloseButton()
        }
        
        bookmarksView.delegate = self
        bookmarksView.dataSource = self
        bookmarksView.register(BookmarkCell.self, forCellWithReuseIdentifier: BookmarkCell.reuseId)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        bookmarksView.addGestureRecognizer(longPressGesture)
        
        layoutViews()
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        if currentDevice == .iPhoneX {
            if #available(iOS 11.0, *) {
                bookmarksView.contentInsetAdjustmentBehavior = .never
                topBar.frame.origin.y = UIProperties.iPhoneXTopInset
            }
        }
        
        topBar.frame.size = CGSize(width: view.frame.width, height: 82)
        
        bookmarksView.frame.origin = topBar.frame.origin
        bookmarksView.frame.size.width = view.frame.width
        bookmarksView.frame.size.height = view.frame.height - topBar.frame.origin.y
        
        bookmarksView.contentInset.top = topBar.frame.height + 4
        bookmarksView.scrollIndicatorInsets.top = bookmarksView.contentInset.top
        bookmarksView.scrollIndicatorInsets.bottom = 5
    }
    
    @objc private func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began :
            let point = gesture.location(in: bookmarksView)
            guard let indexPath = bookmarksView.indexPathForItem(at: point) else { break }
            bookmarksView.beginInteractiveMovementForItem(at: indexPath)
        case .changed :
            let point = gesture.location(in: bookmarksView)
            bookmarksView.updateInteractiveMovementTargetPosition(point)
        case .ended :
            bookmarksView.endInteractiveMovement()
        default :
            bookmarksView.cancelInteractiveMovement()
        }
    }
}

extension BookmarksVC {
    
    func tapCloseButton() {
        dismiss(animated: true)
    }
}

extension BookmarksVC: BookmarkCellDelegate {
    
    func tapMoreButton(_ cell: BookmarkCell) {
        guard let indexPath = bookmarksView.indexPath(for: cell) else { return }
        bookmarksManager.bookmark(for: indexPath.item) { bookmark in
            self.showActions(for: bookmark, at: indexPath)
        }
    }
    
    private func showActions(for bookmark: Bookmark, at indexPath: IndexPath) {
        let actionSheet = RoundActionSheet()
        let removeAction = Action(title: "Remove", type: .destructive) {
            self.removeBookmark(at: indexPath)
        }
        let renameAction = Action(title: "Rename", type: .normal) {
            self.showAlertViewForRenameBookmark(bookmark, at: indexPath)
        }
        actionSheet.addAction(renameAction)
        actionSheet.addAction(removeAction)
        actionSheet.present()
    }
    
    private func renameBookmark(with name: String, at indexPath: IndexPath) {
        bookmarksManager.renameBookmark(with: indexPath.item, with: name) {
            self.bookmarksView.reloadItems(at: [indexPath])
        }
    }
    
    private func removeBookmark(at indexPath: IndexPath) {
        bookmarksManager.removeBookmark(with: indexPath.item) {
            self.bookmarksView.deleteItems(at: [indexPath])
        }
    }
    
    private func showAlertViewForRenameBookmark(_ bookmark: Bookmark, at indexPath: IndexPath) {
        let alertVC = AlertController(message: "Rename Bookmark")
        alertVC.includeTextField = true
        alertVC.allowEmptyTextField = false
        alertVC.showClearButton = true
        alertVC.textFieldPlaceholder = "Name"
        alertVC.textFieldText = bookmark.title
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let renameAction = Action(title: "Save", type: .normal) { 
            let bookmarkName = alertVC.textFieldText!
            self.renameBookmark(with: bookmarkName, at: indexPath)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(renameAction)
        alertVC.present()
    }
}

extension BookmarksVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = bookmarksManager.bookmarksCount
        bookmarksView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookmarkCell.reuseId, for: indexPath) as! BookmarkCell
        cell.delegate = self
        cell.tag += 1
        let tag = cell.tag
        bookmarksManager.bookmark(for: indexPath.item) { bookmark in
            if cell.tag == tag {
                cell.setup(for: bookmark)
            }
        }
        return cell
    }
    
}

extension BookmarksVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        bookmarksManager.bookmark(for: indexPath.item) { bookmark in
            self.dismiss(animated: true)
            self.delegate?.didTapBookmark(with: bookmark.url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        bookmarksManager.moveBookmark(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            topBar.makeOpaque(with: Colors.clearDarkWhite)
        } else {
            topBar.makeTransparent()
        }
    }
    
}

protocol BookmarksDelegate: class {
    
    func didTapBookmark(with url: URL)
}


