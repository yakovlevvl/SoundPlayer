//
//  Bookmark.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 23.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class Bookmark: Object {
    
    @objc dynamic var title = ""
    @objc private(set) dynamic var id = UUID().uuidString
    
    @objc private dynamic var bookmarkUrl = ""
    
    @objc dynamic var orderIndex: Double = 0
    
    var url: URL {
        return URL(string: bookmarkUrl)!
    }
    
    convenience init(url: URL, title: String) {
        self.init()
        self.title = title
        self.bookmarkUrl = url.absoluteString
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
