//
//  Playlist.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class Playlist: Object {
    
    @objc dynamic var title = "Untitled"
    @objc private dynamic var artworkPath: String?
    @objc dynamic var creationDate = Date()
    
    let songs = List<Song>()
    
    var artwork: UIImage? {
        guard let url = artworkPath else { return nil }
        return UIImage(contentsOfFile: url)
    }
    
    var artworkUrl: URL {
        get {
            return URL(fileURLWithPath: artworkPath!)
        }
        set {
            artworkPath = newValue.path
        }
    }
    
}
