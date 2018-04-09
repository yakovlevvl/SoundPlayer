//
//  Playlist.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class Playlist: Compilation {
    
    let songs = List<Song>()
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}


