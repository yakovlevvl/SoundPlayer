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
    
    var browserVC: BrowserVC!
    
    private let downloadService = DownloadService.shared
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Downloads"
        label.frame.size = CGSize(width: 100, height: 26)
        label.font = UIFont(name: Fonts.general, size: 20)
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setImage(UIImage(named: "CloseIcon"), for: .normal)
        button.contentMode = .center
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame.size = CGSize(width: 50, height: 50)
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(UIColor(hex: "D0021B"), for: .normal)
        return button
    }()
    
    private let downloadsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 94)
        layout.sectionInset.top = 20
        layout.sectionInset.bottom = 20
        layout.minimumLineSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(r: 248, g: 248, b: 248)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = UIColor(r: 248, g: 248, b: 248)
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(clearButton)
        view.addSubview(downloadsView)
        
        clearButton.alpha = 0
        
        downloadsView.delegate = self
        downloadsView.dataSource = self
        downloadsView.register(SongDownloadCell.self, forCellWithReuseIdentifier: SongDownloadCell.reuseId)
        
        //downloadService.delegate.remove(browserVC)
        downloadService.delegate.add(self)
        //downloadService.delegate.add(browserVC)
        
        closeButton.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(tapClearButton), for: .touchUpInside)
        
        layoutViews()
    }
    
    private func layoutViews() {
        titleLabel.center.x = view.center.x
        titleLabel.frame.origin.y = 26 

        closeButton.center.y = titleLabel.center.y
        closeButton.frame.origin.x = 14
        
        downloadsView.frame.size = CGSize(width: view.frame.width, height: view.frame.height - 62)
        downloadsView.frame.origin.x = 0
        downloadsView.frame.origin.y = 62
    }
    
    @objc private func tapCloseButton() {
        downloadService.delegate.remove(self)
        dismiss(animated: true)
    }
    
    @objc private func tapClearButton() {
        
    }
    
    private func showInfo(for download: SongDownload) {
        print("showInfo")
    }

}

extension DownloadsVC: SongDownloadCellDelegate {
    
    func tapRemoveButton(_ cell: SongDownloadCell) {
        guard let indexPath = downloadsView.indexPath(for: cell) else { return }
        downloadsManager.download(for: indexPath.item) { download in
            if download.status == .downloaded {
                self.downloadsManager.removeDownload(download) {
                    DispatchQueue.main.async {
                        self.downloadsView.deleteItems(at: [indexPath])
                    }
                }
            } else {
                self.downloadService.cancelDownload(with: download.url)
            }
        }
    }
    
    func tapReloadButton(_ cell: SongDownloadCell) {
        guard let indexPath = downloadsView.indexPath(for: cell) else { return }
        downloadsManager.download(for: indexPath.item) { download in
            self.downloadService.resumeDownload(with: download.url, resumeData: download.resumeData, title: download.title)
        }
    }

}

extension DownloadsVC: DownloadServiceDelegate {
    
    func downloadServiceFinishedDownloading(to location: URL, with title: String, url: URL) {
        //guard let download = download else { return }
        //self.downloadsManager.setupStatus(.downloaded, forDownloadWith: url)
        print("*******WILL reloadItems")
        self.downloadsManager.indexForDownload(with: url) { index in
            print("WILL reloadItems")
            if let index = index {
                print("WILL reloadItems")
                self.downloadsView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
    
    func downloadServiceFailedDownloading(with url: URL) {
        //self.downloadsManager.setupStatus(.downloaded, forDownloadWith: url)
        self.downloadsManager.indexForDownload(with: url) { index in
            if let index = index {
                self.downloadsView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
    
    func downloadServiceDownloadedData(from url: URL, with byteCount: Int64, of totalByteCount: Int64) {
        print("########downloadServiceDownloadedData")
        downloadsManager.download(with: url) { download in
            guard let download = download else { return }
            self.downloadsManager.indexForDownload(with: url) { index in
                guard let index = index else { return }
                guard let cell = self.downloadsView.cellForItem(at: IndexPath(item: index, section: 0)) as? SongDownloadCell else {
                    return
                }
                cell.update(with: download.progress)
                print("downloadProgress \(download.progress.value) ( \(download.progress.description) )")
            }
        }
    }
    
    func downloadServiceCanceledDownloading(with url: URL) {
        downloadsManager.download(with: url) { download in
            guard let download = download else { return }
            self.downloadsManager.indexForDownload(with: url) { index in
                if let index = index {
                    self.downloadsManager.removeDownload(download) {
                        DispatchQueue.main.async {
                            self.downloadsView.deleteItems(at: [IndexPath(item: index, section: 0)])
                        }
                    }
                }
            }
        }
    }
    
    func downloadServiceResumedDownloading(with url: URL) {
        downloadsManager.setupStatus(.downloading, forDownloadWith: url)
        downloadsManager.indexForDownload(with: url) { index in
            if let index = index {
                self.downloadsView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
    
    func downloadServicePausedDownloading(with url: URL, resumeData: Data?, title: String) {
        downloadsManager.setupStatus(.paused, forDownloadWith: url)
        downloadsManager.indexForDownload(with: url) { index in
            if let index = index {
                self.downloadsView.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
    
}

extension DownloadsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadsManager.downloadsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongDownloadCell.reuseId, for: indexPath) as! SongDownloadCell
        cell.delegate = self
        downloadsManager.download(for: indexPath.item) { download in
            cell.setup(for: download)
        }
        return cell
    }
    
}

extension DownloadsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        downloadsManager.download(for: indexPath.item) { download in
            guard download.status != .downloaded else {
                return self.showInfo(for: download)
            }
            if download.status == .downloading {
                self.downloadService.pauseDownload(with: download.url)
            } else if download.status == .paused || download.status == .failed {
                self.downloadService.resumeDownload(with: download.url, resumeData: download.resumeData, title: download.title)
            }
        }
    }
    
}


