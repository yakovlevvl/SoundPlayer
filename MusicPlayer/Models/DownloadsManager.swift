//
//  DownloadsManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 06.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class DownloadsManager {
    
    private let realmQueue = DispatchQueue(label: "com.MusicPlayer.realmQueue", qos: .userInteractive, attributes: .concurrent)
    
    private var downloads: Results<SongDownload> {
        return try! Realm().objects(SongDownload.self).sorted(byKeyPath: "creationDate", ascending: false)
    }
    
    var downloadsCount: Int {
        return try! Realm().objects(SongDownload.self).count
    }
    
    func addDownload(_ download: SongDownload, completion: @escaping () -> ()) {
        realmQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(download)
                }
                realm.refresh()
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func removeDownload(_ download: SongDownload, completion: @escaping () -> ()) {
        let downloadRef = ThreadSafeReference(to: download)
        realmQueue.async {
            let realm = try! Realm()
            guard let download = realm.resolve(downloadRef) else {
                return
            }
            try! realm.write {
                realm.delete(download)
            }
            realm.refresh()
            completion()
        }
    }
    
    func download(for index: Int, completion: @escaping (SongDownload) -> ()) {
        realmQueue.async {
            let download = self.downloads[index]
            let downloadRef = ThreadSafeReference(to: download)
            DispatchQueue.main.async {
                let realm = try! Realm()
                guard let download = realm.resolve(downloadRef) else {
                    return
                }
                completion(download)
            }
        }
    }
    
    func download(with url: URL, completion: @escaping (SongDownload?) -> ()) {
        realmQueue.async {
            guard let download = self.download(with: url) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let downloadRef = ThreadSafeReference(to: download)
            DispatchQueue.main.async {
                let realm = try! Realm()
                guard let download = realm.resolve(downloadRef) else {
                    return completion(nil)
                }
                completion(download)
            }
        }
    }
    
    func indexForDownload(with url: URL, completion: @escaping (Int?) -> ()) {
        realmQueue.async {
            let index = self.downloads.index {
                $0.url == url
            }
            DispatchQueue.main.async {
                completion(index)
            }
        }
    }
    
    func setupStatus(_ status: DownloadStatus, forDownloadWith url: URL) {
        realmQueue.async {
            guard let download = self.download(with: url) else {
                return
            }
            download.status = status
        }
    }
    
    func setupProgress(_ progress: Progress, forDownloadWith url: URL) {
        realmQueue.async {
            guard let download = self.download(with: url) else {
                return
            }
            download.progress = progress
        }
    }
    
    private func download(with url: URL) -> SongDownload? {
        return downloads.filter { $0.url == url }.first
    }
    
    
    
    
    
}
