//
//  PlayerBarObservable.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 11.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    
    static let PlayerBarAppeared = NSNotification.Name("playerBarAppeared")
    
    static let PlayerBarDisappeared = NSNotification.Name("playerBarDisappeared")
}

@objc protocol PlayerBarObservable: class {
    
    @objc func playerBarAppeared()
    
    @objc func playerBarDisappeared()
}

extension PlayerBarObservable where Self: UIViewController {
    
    func setupPlayerBarObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerBarAppeared), name: .PlayerBarAppeared, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerBarDisappeared), name: .PlayerBarDisappeared, object: nil)
    }
    
    func removePlayerBarObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}
