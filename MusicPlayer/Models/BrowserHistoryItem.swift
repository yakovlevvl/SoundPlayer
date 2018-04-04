//
//  BrowserHistoryItem.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 04.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class BrowserHistoryItem: Object {
    
    @objc dynamic var title = ""
    @objc dynamic var visitDate = Date()
    @objc private dynamic var itemUrl = ""
    
    var url: URL {
        return URL(string: itemUrl)!
    }
    
    convenience init(url: URL, title: String) {
        self.init()
        self.title = title
        self.itemUrl = url.absoluteString
    }

}
