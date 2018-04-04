//
//  Song.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class Song: Object {
    
    @objc dynamic var title = ""
    @objc private dynamic var fileSubpath = ""
    @objc private(set) dynamic var duration: Double = 0
    @objc private(set) dynamic var creationDate = Date()
    
    @objc private(set) dynamic var id = UUID().uuidString
    
    @objc dynamic var album: Album?
    
    let playlists = LinkingObjects(fromType: Playlist.self, property: "songs")
    
    var artwork: UIImage? {
        return album?.artwork
    }
    
    var url: URL {
        return URL(fileURLWithPath: filePath)
    }
    
    convenience init(title: String, url: URL) {
        self.init()
        self.title = title
        self.fileSubpath = url.lastPathComponent
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private var filePath: String {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentsUrl.appendingPathComponent("Music").appendingPathComponent(fileSubpath)
        return fileUrl.path
    }
}
