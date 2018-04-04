//
//  BookmarksManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 23.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class BookmarksManager {
    
    private let realmQueue = DispatchQueue(label: "com.MusicPlayer.bookmarksQueue", qos: .userInteractive, attributes: .concurrent)
    
    private var bookmarks: Results<Bookmark> {
        return try! Realm().objects(Bookmark.self).sorted(byKeyPath: "orderIndex")
    }
    
    var bookmarksCount: Int {
        return try! Realm().objects(Bookmark.self).count
    }
    
    func addBookmark(with url: URL, title: String, completion: @escaping () -> ()) {
        realmQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                let bookmark = Bookmark(url: url, title: title)
                let maxIndex = realm.objects(Bookmark.self).max(ofProperty: "orderIndex") as Double? ?? 0
                let orderIndex = maxIndex + 1
                bookmark.orderIndex = orderIndex
                
                try! realm.write {
                    realm.add(bookmark)
                }
                DispatchQueue.global(qos: .userInteractive).async {
                    try! Realm().refresh()
                    completion()
                }
            }
        }
    }
    
    func moveBookmark(fromIndex: Int, toIndex: Int) {
        let bookmarks = self.bookmarks
        let bookmark = bookmarks[fromIndex]
        let maxIndex = bookmarksCount - 1
        let firstIndex = bookmarks[toIndex].orderIndex
        var secondIndex = 0.0
        if toIndex > fromIndex {
            secondIndex = toIndex != maxIndex ? bookmarks[toIndex + 1].orderIndex : firstIndex + 1
        } else {
            secondIndex = toIndex != 0 ? bookmarks[toIndex - 1].orderIndex : 0
        }
        let newIndex = (firstIndex + secondIndex)/2
        let realm = try! Realm()
        try! realm.write {
            bookmark.orderIndex = newIndex
        }
        realm.refresh()
    }
    
    func removeBookmark(with index: Int, completion: @escaping () -> ()) {
        realmQueue.async {
            let bookmark = self.bookmarks[index]
            self.removeBookmark(bookmark) {
                completion()
            }
        }
    }
    
    func removeBookmark(with id: String, completion: @escaping () -> ()) {
        realmQueue.async {
            guard let bookmark = self.bookmark(with: id) else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            self.removeBookmark(bookmark) {
                completion()
            }
        }
    }
    
    func renameBookmark(with index: Int, with name: String, completion: @escaping () -> ()) {
        realmQueue.async {
            let bookmark = self.bookmarks[index]
            let realm = try! Realm()
            try! realm.write {
                bookmark.title = name
            }
            DispatchQueue.main.async {
                try! Realm().refresh()
                completion()
            }
        }
    }
    
    func renameBookmark(with id: String, with name: String, completion: @escaping () -> ()) {
        realmQueue.async {
            guard let bookmark = self.bookmark(with: id) else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            let realm = try! Realm()
            try! realm.write {
                bookmark.title = name
            }
            DispatchQueue.main.async {
                try! Realm().refresh()
                completion()
            }
        }
    }
    
    private func removeBookmark(_ bookmark: Bookmark, completion: @escaping () -> ()) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(bookmark)
        }
        DispatchQueue.main.async {
            try! Realm().refresh()
            completion()
        }
    }
    
    
    
    func bookmark(for index: Int, completion: @escaping (Bookmark) -> ()) {
        realmQueue.async {
            let bookmark = self.bookmarks[index]
            let bookmarkRef = ThreadSafeReference(to: bookmark)
            DispatchQueue.main.async {
                let realm = try! Realm()
                guard let bookmark = realm.resolve(bookmarkRef) else {
                    return
                }
                completion(bookmark)
            }
        }
    }
    
    private func bookmark(with id: String) -> Bookmark? {
        return try! Realm().object(ofType: Bookmark.self, forPrimaryKey: id)
    }
    
}
