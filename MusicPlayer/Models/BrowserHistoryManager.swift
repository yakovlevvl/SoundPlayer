//
//  BrowserHistoryManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 04.03.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class BrowserHistoryManager {
    
    private let realmQueue = DispatchQueue(label: "com.MusicPlayer.historyQueue", qos: .userInteractive, attributes: .concurrent)
    
    private var items: Results<BrowserHistoryItem> {
        return try! Realm().objects(BrowserHistoryItem.self).sorted(byKeyPath: "visitDate", ascending: false)
    }
    
    var itemsCount: Int {
        return try! Realm().objects(BrowserHistoryItem.self).count
    }
    
    func addItem(with url: URL, title: String, completion: @escaping () -> () = {}) {
        realmQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                if let item = self.item(with: url) {
                    try! realm.write {
                        item.visitDate = Date()
                        item.title = title
                    }
                } else {
                    let item = BrowserHistoryItem(url: url, title: title)
                    try! realm.write {
                        realm.add(item)
                    }
                }
                DispatchQueue.main.async {
                    try! Realm().refresh()
                    completion()
                }
            }
        }
    }
    
    func item(for index: Int, completion: @escaping (BrowserHistoryItem) -> ()) {
        realmQueue.async {
            let item = self.items[index]
            let itemRef = ThreadSafeReference(to: item)
            DispatchQueue.main.async {
                let realm = try! Realm()
                guard let item = realm.resolve(itemRef) else {
                    return
                }
                completion(item)
            }
        }
    }
    
    func clearHistory(completion: @escaping () -> ()) {
        realmQueue.async {
            guard let realm = try? Realm() else { return }
            let items = realm.objects(BrowserHistoryItem.self)
            try? realm.write {
                realm.delete(items)
            }
            DispatchQueue.main.async {
                try! Realm().refresh()
                completion()
            }
        }
    }
    
    private func item(with url: URL) -> BrowserHistoryItem? {
        return try! Realm().objects(BrowserHistoryItem.self).filter("itemUrl = %@", url.absoluteString).first
    }
}
