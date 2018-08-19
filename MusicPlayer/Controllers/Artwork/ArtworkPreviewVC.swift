//
//  ArtworkPreviewVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 27.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class ArtworkPreviewVC: UIViewController {
    
    var artwork: UIImage!
    
    weak var delegate: ArtworkPreviewDelegate?
    
    private let closeButton: RoundButton = {
        let button = RoundButton(type: .custom)
        button.frame.size = CGSize(width: 60, height: 60)
        button.backgroundColor = Colors.darkWhite
        button.setImage(UIImage(named: "CloseIcon"))
        return button
    }()
    
    private let doneButton: RoundButton = {
        let button = RoundButton(type: .custom)
        button.frame.size = CGSize(width: 60, height: 60)
        button.backgroundColor = Colors.darkWhite
        button.setImage(UIImage(named: "Checkmark"))
        button.tintColor = .black
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .black
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    private let frameLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        return layer
    }()
    
    private let maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor(white: 0, alpha: 0.6).cgColor
        return layer
    }()
    
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        maskLayer.addSublayer(frameLayer)
        view.layer.addSublayer(maskLayer)
        
        view.addSubview(doneButton)
        view.addSubview(closeButton)

        imageView.image = artwork
        imageView.contentMode = .center
        
        doneButton.addTarget(self, action: #selector(tapDoneButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(tapCloseButton), for: .touchUpInside)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        layoutViews()
    }
    
    private func layoutViews() {
        scrollView.frame = view.bounds
        imageView.frame.size = artwork.size
        scrollView.contentSize = imageView.frame.size
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        scrollView.minimumZoomScale = max(scrollView.bounds.width/imageView.bounds.width,
            scrollView.bounds.width/imageView.bounds.height)
        scrollView.zoomScale = scrollView.minimumZoomScale
        
        scrollView.contentOffset = CGPoint(x: imageView.frame.width/2 - scrollView.frame.width/2,
            y: imageView.frame.height/2 - scrollView.frame.height/2)
        
        closeButton.frame.origin.x = 40
        closeButton.center.y = view.frame.height - 62
        doneButton.center.y = closeButton.center.y
        doneButton.frame.origin.x = view.frame.width - doneButton.frame.width - 40
        
        layoutMaskLayer()
    }
    
    private func layoutMaskLayer() {
        let maskPath = UIBezierPath(rect: view.bounds)
        
        let frameWidth = view.frame.width
        let frameSize = CGSize(width: frameWidth, height: frameWidth)
        let frameOrigin = CGPoint(x: 0, y: view.frame.height/2 - frameWidth/2)
        
        let framePath = UIBezierPath(rect: CGRect(origin: frameOrigin, size: frameSize))
        
        maskPath.append(framePath)
        
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        frameLayer.frame = CGRect(origin: frameOrigin, size: frameSize)
    }
    
    @objc private func tapCloseButton() {
        dismiss(animated: true)
    }
    
    @objc private func tapDoneButton() {
        cropArtwork { croppedImage in
            self.dismiss(animated: true)
            self.delegate?.artworkDidCrop(croppedImage)
        }
    }
    
    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let scrollView = recognizer.view as! UIScrollView
        scrollView.setZoomScale(scrollView.zoomScale > scrollView.minimumZoomScale ? scrollView.minimumZoomScale : scrollView.maximumZoomScale, animated: true)
    }
    
    private func cropArtwork(completion: @escaping (UIImage) -> ()) {
        let scale = 1/scrollView.zoomScale
        let width = frameLayer.frame.width * scale
        let height = frameLayer.frame.height * scale
        let x = (scrollView.contentOffset.x + frameLayer.frame.origin.x) * scale
        let y = (scrollView.contentOffset.y + frameLayer.frame.origin.y) * scale
        let cropFrame = CGRect(x: x, y: y, width: width, height: height)
        let croppedImage = UIImage(cgImage: artwork.cgImage!.cropping(to: cropFrame)!)
        let size = UIProperties.Player.artworkWidth
        croppedImage.resizeAsync(to: CGSize(width: size, height: size)) { image in
            completion(image)
        }
    }
}

extension ArtworkPreviewVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageSize = imageView.frame.size
        let scrollSize = scrollView.frame.size
        
        let verticalPadding = view.frame.height/2 - view.frame.width/2
        let horizontalPadding = imageSize.width < scrollSize.width ? (scrollSize.width - imageSize.width)/2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding,
            bottom: verticalPadding, right: horizontalPadding)
    }
}

protocol ArtworkPreviewDelegate: class {
    
    func artworkDidCrop(_ image: UIImage)
}


