//
//  Album.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class Album: Compilation {
    
    @objc dynamic var artist = ""
    
    let songs = LinkingObjects(fromType: Song.self, property: "album")
    
    convenience init(title: String, artist: String) {
        self.init()
        self.title = title
        self.artist = artist
    }
}

