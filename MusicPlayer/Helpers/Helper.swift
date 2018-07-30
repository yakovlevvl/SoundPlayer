//
//  Helper.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import Photos

enum Fonts {
    
    static let general = "Circe-Bold"
    static let gotham = "GothamPro-Medium"
}

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

enum Colors {
    
    static let general = UIColor(r: 252/255, g: 252/255, b: 252/255, a: 1)
    static let darkWhite = UIColor(r: 250, g: 250, b: 250)
    static let clearDarkWhite = UIColor(r: 250, g: 250, b: 250, a: 0.98)
    static let clearWhite = UIColor(r: 255, g: 255, b: 255, a: 0.98)
    static let red = UIColor(hex: "D0021B")
    static let clearRed = UIColor(hex: "D0021B", alpha: 0.3)
    static let roundButtonColor = UIColor(hex: "D82C41")
    static let switchColor = UIColor(hex: "D0021B", alpha: 0.7)
    static let gray = UIColor(r: 236, g: 236, b: 236)
}

enum UserDefaultsKeys {
    
    static let notFirstLaunch = "notFirstLaunch"
    static let browserLastUrl = "browserLastUrl"
    
    static let songsSortMethod = "songsSortMethod"
    static let albumsSortMethod = "albumsSortMethod"
    static let playlistsSortMethod = "playlistsSortMethod"
    
    static let enableSpotlight = "enableSpotlight"
    static let browserNeedReset = "browserNeedReset"
    
    static let appOpenedCount = "appOpenedCount"
}

enum PlayerBarProperties {
    
    static let barHeight: CGFloat = 68
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    convenience init(hex: String, alpha: CGFloat = 1) {
        self.init(r: CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF), g: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF), b: CGFloat((Int(hex, radix: 16)!) & 0xFF), a: alpha)
    }
}

extension FileManager {
    
    func directoryExists(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}

extension UIView {
    
    class func animate(_ duration: Double, delay: Double = 0, damping: CGFloat, velocity: CGFloat, options: UIViewAnimationOptions = [], animation: @escaping () -> (), completion: @escaping (Bool) -> ()) {
        animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: animation, completion: completion)
    }
    
    class func animate(_ duration: Double, delay: Double = 0, damping: CGFloat, velocity: CGFloat, options: UIViewAnimationOptions = [], animation: @escaping () -> ()) {
        animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: animation)
    }
    
    class func animate(_ duration: Double, options: UIViewAnimationOptions = [], animation: @escaping () -> (), completion: @escaping (Bool) -> ()) {
        animate(withDuration: duration, delay: 0, options: options, animations: animation, completion: completion)
    }
    
    class func animate(_ duration: Double, options: UIViewAnimationOptions = [], animation: @escaping () -> ()) {
        animate(withDuration: duration, delay: 0, options: options, animations: animation)
    }
    
    convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
    }
    
}

extension UIViewController {
    
    func removeFromParent() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
    
    func addChildController(_ childController: UIViewController) {
        addChildViewController(childController)
        view.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
    
    func addChildController(_ childController: UIViewController, parentView: UIView) {
        addChildViewController(childController)
        parentView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
    
    class func instantiate(_ storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)) -> Self {
        return instantiateHelper(storyboard)
    }
    
    private class func instantiateHelper<T>(_ storyboard: UIStoryboard) -> T {
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! T
    }
}

extension URLSessionDownloadTask {
    
    var id: String? {
        get {
            return getValueOfProperty(with: "id")
        }
        set {
            setValue(newValue, ofPropertyWith: "id")
        }
    }
    
    var title: String? {
        get {
            return getValueOfProperty(with: "title")
        }
        set {
            setValue(newValue, ofPropertyWith: "title")
        }
    }
    
    private func getValueOfProperty(with name: String) -> String? {
        guard let description = taskDescription, !description.isEmpty else { return nil }
        guard let data = description.data(using: .utf8) else { return nil }
        guard let json = (try? JSONSerialization.jsonObject(with: data))
            as? [String : String] else { return nil }
        return json[name]
    }
    
    private func setValue(_ value: String?, ofPropertyWith name: String) {
        var json = [String : String]()
        if let description = taskDescription, !description.isEmpty {
            guard let data = description.data(using: .utf8) else { return }
            guard let jsonObject = (try? JSONSerialization.jsonObject(with: data))
                as? [String : String] else { return }
            json = jsonObject
        }
        json[name] = value
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return }
        taskDescription = String(data: data, encoding: .utf8)
    }
    
    var url: URL? {
        guard let originalRequestUrl = originalRequest?.url else {
            return currentRequest?.url
        }
        return originalRequestUrl
    }
}

extension FileManager {
    
    func changeUrlIfExists(_ url: URL) -> URL {
        var url = url
        var index = 1
        while fileExists(atPath: url.path) {
            var pathComponent = url.deletingPathExtension().lastPathComponent
            if index > 1 {
                pathComponent = pathComponent.replacingOccurrences(of: "\(index - 1)", with: "")
            }
            pathComponent += "\(index)"
            url = url.deletingLastPathComponent().appendingPathComponent(pathComponent)
                .appendingPathExtension(url.pathExtension)
            index += 1
        }
        return url
    }
}

extension Array where Element: Hashable {
    
    func after(item: Element) -> Element? {
        if let index = index(of: item), index + 1 < count {
            return self[index + 1]
        }
        return nil
    }
    
    func before(item: Element) -> Element? {
        if let index = index(of: item), index > 0 {
            return self[index - 1]
        }
        return nil
    }
}

extension MutableCollection where Index == Int {
    
    mutating func shuffle() {
        
        if count < 2 { return }
        
        for i in stride(from: count - 1, through: 1, by: -1) {
            let j = Int(arc4random_uniform(UInt32(i + 1)))
            if i != j {
                swapAt(i, j)
            }
        }
    }
}

extension String {
    
    func textSizeForMaxWidth(_ width: CGFloat, font: UIFont) -> CGSize {
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics], attributes: [NSAttributedStringKey.font : font as Any], context: nil).size
    }
}

extension NSAttributedString {
    
    func textSizeForMaxWidth(_ width: CGFloat) -> CGSize {
        return boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading, .usesDeviceMetrics], context: nil).size
    }
}

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            layer.cornerRadius = radius
            guard !corners.contains(.allCorners) else { return }
            layer.maskedCorners = []
            if corners.contains(.topLeft) {
                layer.maskedCorners.insert(.layerMaxXMinYCorner)
            }
            if corners.contains(.topRight) {
                layer.maskedCorners.insert(.layerMinXMinYCorner)
            }
            if corners.contains(.bottomLeft) {
                layer.maskedCorners.insert(.layerMinXMaxYCorner)
            }
            if corners.contains(.bottomRight) {
                layer.maskedCorners.insert(.layerMaxXMaxYCorner)
            }
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

extension UIImage {
    
    class func roundImage(color: UIColor, diameter: CGFloat, shadow: Bool) -> UIImage {
        
        //we will make circle with this diameter
        let edgeLen: CGFloat = diameter
        
        //circle will be created from UIView
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: edgeLen, height: edgeLen))
        circle.backgroundColor = color
        circle.clipsToBounds = true
        circle.isOpaque = false
        
        //in the layer we add corner radius to make it circle and add shadow
        circle.layer.cornerRadius = edgeLen/2
        
        if shadow {
            circle.layer.shadowColor = UIColor.gray.cgColor
            circle.layer.shadowOffset = .zero
            circle.layer.shadowRadius = 2
            circle.layer.shadowOpacity = 0.4
            circle.layer.masksToBounds = false
        }
        
        //we add circle to a view, that is bigger than circle so we have extra 10 points for the shadow
        let view = UIView(frame: CGRect(x: 0, y: 0, width: edgeLen+10, height: edgeLen+10))
        view.backgroundColor = UIColor.clear
        view.addSubview(circle)
        
        circle.center = view.center
        
        //here we are rendering view to image, so we can use it later
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

enum ScreenWidth {
    
    static let iPhone5: CGFloat = 320
    static let iPhone6: CGFloat = 375
    static let iPhone6Plus: CGFloat = 414
    static let iPhoneX: CGFloat = 375
}

enum Device: CGFloat {
    
    case iPhone5 = 320
    case iPhone6, iPhoneX = 375
    case iPhone6Plus = 414
}

var currentDevice: Device {
    switch screenWidth {
    case ScreenWidth.iPhone5 : return .iPhone5
    case ScreenWidth.iPhone6 : return .iPhone6
    case ScreenWidth.iPhoneX : return .iPhoneX
    case ScreenWidth.iPhone6Plus : return .iPhone6Plus
    default : return .iPhoneX
    }
}

struct Screen {
    
    static var is4inch: Bool {
        return screenWidth == ScreenWidth.iPhone5
    }
    
    static var is4_7inch: Bool {
        return screenWidth == ScreenWidth.iPhone6
    }
    
    static var is5_5inch: Bool {
        return screenWidth == ScreenWidth.iPhone6Plus
    }
    
    static var is5_8inch: Bool {
        return screenWidth == ScreenWidth.iPhoneX
    }
}

extension PHPhotoLibrary {
    
    class func checkStatus(completion: @escaping (Bool) -> ()) {
        if authorizationStatus() == .authorized {
            completion(true)
        } else {
            requestAuthorization { status in
                if status == .authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}

extension CALayer {
    
    func disableAnimation() {
        actions = ["position": NSNull(), "onOrderIn": NSNull(), "onOrderOut": NSNull(), "sublayers": NSNull(), "contents": NSNull(), "bounds": NSNull()]
    }
}

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

extension UIImage {
    
    func resizeAsync(to size: CGSize, completion: @escaping (UIImage) -> ()) {
        guard size.width < self.size.width, size.height < self.size.height else {
            return completion(self)
        }
        
        let width = size.width*UIScreen.main.scale
        let height = size.height*UIScreen.main.scale

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let context = CGContext(data: nil, width: Int(width), height: Int(height),
                bitsPerComponent: 8, bytesPerRow: Int(width)*4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            
            context.draw(self.cgImage!, in: rect)
            
            let resizedImage = UIImage(cgImage: context.makeImage()!)
            
            DispatchQueue.main.async {
                completion(resizedImage)
            }
        }
    }
    
    func resize(to size: CGSize) -> UIImage {
        guard size.width < self.size.width, size.height < self.size.height else {
            return self
        }
        
        let width = size.width*UIScreen.main.scale
        let height = size.height*UIScreen.main.scale
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        let context = CGContext(data: nil, width: Int(width), height: Int(height),
                                bitsPerComponent: 8, bytesPerRow: Int(width)*4, space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        context.draw(self.cgImage!, in: rect)
        
        let resizedImage = UIImage(cgImage: context.makeImage()!)
        
        return resizedImage
    }
    
    func imageData() -> Data? {
        return UIImageJPEGRepresentation(self, 1)
    }
}


