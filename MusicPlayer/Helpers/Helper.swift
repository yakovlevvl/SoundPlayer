//
//  Helper.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

enum Fonts {
    
    static let general = "Circe-Bold"
    static let gotham = "GothamPro-Medium"
}

enum Colors {
    
    static let general = UIColor(red: 252/255, green: 252/255, blue: 252/255, alpha: 1)
    
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
