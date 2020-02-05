//
//  AddArtworkVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 27.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import Photos

final class AddArtworkVC: UIViewController {
    
    weak var delegate: AddArtworkDelegate?
    
    private var assets = PHFetchResult<PHAsset>()
    private let imageManager = PHImageManager.default()
    private let requestOptions = PHImageRequestOptions()

    private var imageSize = CGSize()
    
    private var accessAllowed = false
    
    private let topBar: ClearTopBar = {
        let topBar = ClearTopBar()
        topBar.title = "Add Artwork"
        topBar.includeRightButton = false
        topBar.setLeftButtonImage(UIImage(named: "CloseIcon"))
        return topBar
    }()
    
    private let photosView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var allowAccessView: AlertView = {
        let view = AlertView(frame: photosView.bounds)
        view.textBackgroundColor = Colors.darkWhite
        view.textColor = Colors.red
        view.text = "Allow Photos access"
        view.onTap = allowAccess
        return view
    }()
    
    private lazy var noPhotosView: AlertView = {
        let view = AlertView(frame: photosView.bounds)
        view.text = "No Photos"
        return view
    }()
    
    private let transitionManager = VerticalTransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        view.addSubview(photosView)
        
        topBar.onLeftButtonTapped = { [unowned self] in
            self.tapCloseButton()
        }
        
        photosView.delegate = self
        photosView.dataSource = self
        photosView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseId)
        
        layoutViews()
        
        PHPhotoLibrary.checkStatus { status in
            if status {
                self.accessAllowed = true
                self.setupRequestOptions()
                self.fetchAssets()
            }
        }
    }
    
    private func layoutViews() {
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 74)
        
        if currentDevice == .iPhoneX {
            if #available(iOS 11.0, *) {
                photosView.contentInsetAdjustmentBehavior = .never
                topBar.frame.origin.y = UIProperties.iPhoneXTopInset
            }
        }
        
        photosView.frame.origin.x = 0
        photosView.frame.origin.y = topBar.frame.maxY
        photosView.frame.size.width = view.frame.width
        photosView.frame.size.height = view.frame.height - photosView.frame.minY
    
        let layout = photosView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let itemsCountPerLine: CGFloat = 3
        
        let freeSpace = layout.minimumInteritemSpacing*(itemsCountPerLine - 1) +
            layout.sectionInset.left + layout.sectionInset.right
        
        let cellWidth = (view.frame.width - freeSpace)/itemsCountPerLine
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        let scale = UIScreen.main.scale
        imageSize = CGSize(width: cellWidth*scale, height: cellWidth*scale)
    }
    
    private func setupRequestOptions() {
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
    }
    
    private func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        assets = PHAsset.fetchAssets(with: .image, options: options)
        DispatchQueue.main.async {
            self.photosView.reloadData()
        }
    }

    private func tapCloseButton() {
        dismiss(animated: true)
    }
    
    private func allowAccess() {
        print("allowAccess")
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
    }
    
    private func showPreview(for image: UIImage) {
        let artworkPreviewVC = ArtworkPreviewVC()
        artworkPreviewVC.delegate = self
        artworkPreviewVC.artwork = image
        artworkPreviewVC.modalPresentationStyle = .fullScreen
        artworkPreviewVC.transitioningDelegate = transitionManager
        present(artworkPreviewVC, animated: true)
    }

}

extension AddArtworkVC: ArtworkPreviewDelegate {
    
    func artworkDidCrop(_ image: UIImage) {
        dismiss(animated: true)
        delegate?.didSelectArtwork(image)
    }
}

extension AddArtworkVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = assets.count
        photosView.backgroundView = count == 0 ? (accessAllowed ? noPhotosView : allowAccessView) : nil
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseId, for: indexPath) as! ImageCell
        
        cell.setImage(nil)
        imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        
        DispatchQueue.global(qos: .userInteractive).async {
            let id = self.imageManager.requestImage(for: self.assets[indexPath.item], targetSize: self.imageSize,
                contentMode: .aspectFill, options: self.requestOptions) { image, info in
                
                DispatchQueue.main.async {
                    if cell.tag == info![PHImageResultRequestIDKey] as! Int {
                        cell.setImage(image)
                        cell.alpha = 0
                        UIView.animate(0.1, options: .allowUserInteraction) {
                            cell.alpha = 1
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                cell.tag = Int(id)
            }
        }

        return cell
    }
}

extension AddArtworkVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        imageManager.requestImage(for: asset, targetSize: targetSize,
            contentMode: .aspectFill, options: requestOptions) { image, info in
            if let image = image {
                self.showPreview(for: image)
            }
        }
    }
}

protocol AddArtworkDelegate: class {
    
    func didSelectArtwork(_ image: UIImage)
}

