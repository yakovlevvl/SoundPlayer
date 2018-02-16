//
//  DownloadsManager.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 06.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class DownloadsManager {
    
    private var realm: Realm!
    
    //private var downloads: Results<SongDownload>!
    
    var queue = DispatchQueue(label: "realm")
    
    private var downloads: Results<SongDownload> {
        
    }
    
    var downloadsCount: Int {
        return try! Realm().objects(SongDownload.self).count
    }
    
    init() {
        queue = DispatchQueue(label: "realm")
        queue.async {
            Realm.asyncOpen(configuration: Realm.Configuration.defaultConfiguration) { realm, error in
                if let realm = realm {
                    self.realm = realm
                    self.downloads = self.realm.objects(SongDownload.self).sorted(byKeyPath: "creationDate")
                    // Realm successfully opened, with migration applied on background thread
                } else if let error = error {
                    // Handle error that occurred while opening the Realm
                }
            }
            //self.realm = try! Realm()
//            self.downloads = self.realm.objects(SongDownload.self).sorted(byKeyPath: "creationDate")
        }
    }
    
    func addDownload(_ download: SongDownload) {
        queue.async {
            autoreleasepool {
            try! self.realm.write {
                self.realm.add(download)
            }
            self.realm.refresh()
            }
        }
    }
    
    func removeDownload(_ download: SongDownload) {
        queue.async {
            try! self.realm.write {
                self.realm.delete(download)
            }
            self.realm.refresh()
        }
    }
    
    func download(for index: Int, completion: @escaping (SongDownload) -> ()) {
        queue.async {
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
        queue.async {
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
        queue.async {
            let index = self.downloads.index {
                $0.url == url
            }
            DispatchQueue.main.async {
                completion(index)
            }
        }
    }
    
    func setupStatus(_ status: DownloadStatus, forDownloadWith url: URL) {
        queue.async {
            guard let download = self.download(with: url) else {
                return
            }
            //try! self.realm.write {
                download.status = status
            //}
            self.realm.refresh()
        }
    }
    
    func setupProgress(_ progress: Progress, forDownloadWith url: URL) {
        queue.async {
            guard let download = self.download(with: url) else {
                return
            }
            //try! self.realm.write {
                download.progress = progress
            //}
            self.realm.refresh()
        }
    }
    
    private func download(with url: URL) -> SongDownload? {
        return downloads.filter { $0.url == url }.first
    }
    
    
    
    
    
}
