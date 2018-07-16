//
//  DownloadsVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 07.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class DownloadsVC: UIViewController {
    
    var downloadsManager: DownloadsManager!
    
    private let downloadService = DownloadService.shared()
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Downloads"
        topBar.setRightButtonFontSize(19)
        topBar.setRightButtonTitle("Clear")
        topBar.setRightButtonTitleColor(Colors.red)
        topBar.setLeftButtonImage(UIImage(named: "CloseIcon"))
        return topBar
    }()
    
    private let downloadsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.bottom = 20
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: screenWidth - 40, height: 94)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Colors.darkWhite
        return collectionView
    }()
    
    private lazy var alertView: AlertView = {
        let view = AlertView(frame: downloadsView.bounds)
        view.text = "Downloaded music will appear here."
        view.icon = UIImage(named: "MusicIcon")!
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = Colors.darkWhite
        
        view.addSubview(downloadsView)
        view.addSubview(topBar)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapCloseButton()
        }
        topBar.onRightButtonTapped = { [unowned self] in
            self.tapClearButton()
        }
        
        downloadsView.delegate = self
        downloadsView.dataSource = self
        downloadsView.register(SongDownloadCell.self, forCellWithReuseIdentifier: SongDownloadCell.reuseId)
        
        layoutViews()
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 82)
        
        downloadsView.frame = view.frame
        downloadsView.contentInset.top = topBar.frame.height + 4
        downloadsView.scrollIndicatorInsets.top = downloadsView.contentInset.top
        downloadsView.scrollIndicatorInsets.bottom = 5
    }
    
    private func playSong(from download: SongDownload) {
        if let song = download.song {
            Player.main.play(song: song)
        }
    }
    
    private func pauseDownload(_ download: SongDownload) {
        downloadService.pauseDownload(with: download.url)
    }
    
    private func resumeDownload(_ download: SongDownload) {
        downloadService.resumeDownload(with: download.url, resumeData: download.resumeData, title: download.title, id: download.id)
    }
    
    private func removeDownload(at indexPath: IndexPath) {
        downloadsManager.removeDownload(with: indexPath.item) {
            self.downloadsView.deleteItems(at: [indexPath])
        }
    }
    
    private func checkFinishedDownloadsCount() {
        DispatchQueue.global(qos: .userInteractive).async {
            let count = self.downloadsManager.finishedDownloadsCount
            DispatchQueue.main.async {
                if count == 0 {
                    self.topBar.hideRightButton()
                } else {
                    self.topBar.showRightButton()
                }
            }
        }
    }
}

extension DownloadsVC {
    
    func tapCloseButton() {
        dismiss(animated: true)
    }
    
    func tapClearButton() {
        let alertVC = AlertController(message: "Clear finished downloads ?")
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let clearAction = Action(title: "Clear", type: .destructive) {
            self.clearFinishedDownloads()
        }
        alertVC.addAction(clearAction)
        alertVC.addAction(cancelAction)
        alertVC.present()
    }
    
    private func clearFinishedDownloads() {
        downloadsManager.clearFinishedDownloads {
            self.downloadsView.reloadData()
        }
    }
}

extension DownloadsVC: SongDownloadCellDelegate {
    
    func tapRemoveButton(_ cell: SongDownloadCell) {
        guard let indexPath = downloadsView.indexPath(for: cell) else { return }
        downloadsManager.download(for: indexPath.item) { download in
            if download.status == .downloading || download.status == .preparing {
                self.downloadService.cancelDownload(with: download.url)
            }
            self.removeDownload(at: indexPath)
        }
    }
    
    func tapReloadButton(_ cell: SongDownloadCell) {
        guard let indexPath = downloadsView.indexPath(for: cell) else { return }
        downloadsManager.download(for: indexPath.item) { download in
            self.resumeDownload(download)
        }
    }
}

extension DownloadsVC: BrowserDownloadDelegate {
    
    func browserFailedDownload(with id: String) {
        updateCellForDownload(with: id)
    }
    
    func browserPausedDownload(with id: String) {
        updateCellForDownload(with: id)
    }
    
    func browserStartedDownload(with id: String) {
        updateCellForDownload(with: id)
    }
    
    func browserResumedDownload(with id: String) {
        updateCellForDownload(with: id)
    }
    
    func browserFinishedDownload(with id: String) {
        updateCellForDownload(with: id)
    }
    
    func browserUpdatedDownload(with id: String, with progress: Progress) {
        downloadsManager.indexForDownload(with: id) { index in
            guard let index = index else { return }
            if let cell = self.downloadsView.cellForItem(at: IndexPath(item: index, section: 0))
                as? SongDownloadCell {
                cell.update(with: progress)
            }
        }
    }
    
    private func updateCellForDownload(with id: String) {
        downloadsManager.indexForDownload(with: id) { index in
            guard let index = index else { return }
            let indexPath = IndexPath(item: index, section: 0)
            guard self.downloadsView.cellForItem(at: indexPath) != nil else { return }
            self.downloadsView.reloadItems(at: [indexPath])
        }
    }
}

extension DownloadsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = downloadsManager.downloadsCount
        checkFinishedDownloadsCount()
        downloadsView.backgroundView = count == 0 ? alertView : nil
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongDownloadCell.reuseId, for: indexPath) as! SongDownloadCell
        cell.delegate = self
        cell.tag += 1
        let tag = cell.tag
        downloadsManager.download(for: indexPath.item) { download in
            if cell.tag == tag {
                cell.setup(for: download)
            }
        }
        return cell
    }
}

extension DownloadsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        downloadsManager.download(for: indexPath.item) { download in
            self.didSelectDownload(download, at: indexPath)
        }
    }
    
    private func didSelectDownload(_ download: SongDownload, at indexPath: IndexPath) {
        switch download.status {
        case .downloaded : playSong(from: download)
        case .downloading : pauseDownload(download)
        case .paused : resumeDownload(download)
        case .failed : showActionsForFailedDownload(download, at: indexPath)
        case .preparing : break
        }
    }
    
    private func showActionsForFailedDownload(_ download: SongDownload, at indexPath: IndexPath) {
        let actionSheet = RoundActionSheet()
        let reloadAction = Action(title: "Try again", type: .normal) {
            self.resumeDownload(download)
        }
        let removeAction = Action(title: "Remove", type: .destructive) {
            self.removeDownload(at: indexPath)
        }
        actionSheet.addAction(reloadAction)
        actionSheet.addAction(removeAction)
        actionSheet.present()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > -scrollView.contentInset.top {
            topBar.makeOpaque(with: Colors.clearDarkWhite)
        } else {
            topBar.makeTransparent()
        }
    }
}

