//
//  ImageView.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 19.08.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class ImageView: UIView {
    
    var image: UIImage? {
        willSet {
            guard let image = newValue else {
                layer.contents = nil
                return
            }
            
            if image.size.width <= bounds.width, image.size.height <= bounds.height {
                layer.contents = image.cgImage
            } else {
                drawImage(image)
            }
        }
    }
    
    override var contentMode: UIViewContentMode {
        didSet {
            switch contentMode {
            case .center:
                layer.contentsGravity = kCAGravityCenter
            default:
                layer.contentsGravity = kCAGravityResizeAspectFill
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .center
        layer.disableAnimation()
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let currentImage = image
        image = currentImage
    }
    
    private func drawImage(_ image: UIImage) {
        let width = bounds.width*UIScreen.main.scale
        let height = bounds.height*UIScreen.main.scale
        
        if width == 0 || height == 0 {
            layer.contents = image.cgImage
            return
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let context = CGContext(data: nil, width: Int(width), height: Int(height),
                                    bitsPerComponent: 8, bytesPerRow: Int(width)*4, space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            
            context.draw(image.cgImage!, in: rect)
            
            let decodedImage = context.makeImage()!
            
            DispatchQueue.main.async {
                self.layer.contents = decodedImage
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

