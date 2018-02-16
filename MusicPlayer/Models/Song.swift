//
//  Song.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class Song: Object {
    
    @objc dynamic var title = "Unknown"
    @objc dynamic var duration: Double = 0
    @objc dynamic var creationDate = Date()
    @objc private dynamic var filePath = ""
    
    @objc dynamic var album: Album?
    
    var artwork: UIImage? {
        return album?.artwork
    }
    
    convenience init(url: URL) {
        self.init()
        self.url = url
    }
    
    var url: URL {
        get {
            return URL(fileURLWithPath: filePath)
        }
        set {
            filePath = newValue.path
        }
    }
    
    
}
