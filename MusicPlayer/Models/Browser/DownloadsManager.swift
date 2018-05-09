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
    
    private var finishedDownloads: Results<SongDownload> {
        return try! Realm().objects(SongDownload.self).filter("downloadStatus = %@", DownloadStatus.downloaded.rawValue)
    }
    
    var downloadsCount: Int {
        return try! Realm().objects(SongDownload.self).count
    }
    
    var finishedDownloadsCount: Int {
        return finishedDownloads.count
    }
    
    func addDownload(_ download: SongDownload, completion: @escaping () -> ()) {
        realmQueue.async {
            autoreleasepool {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(download)
                }
                DispatchQueue.main.async {
                    try! Realm().refresh()
                    completion()
                }
            }
        }
    }
    
    func addDownload(with url: URL, title: String, completion: @escaping (String) -> ()) {
        realmQueue.async {
            autoreleasepool {
                let download = SongDownload(url: url, title: title)
                let id = download.id
                let realm = try! Realm()
                try! realm.write {
                    realm.add(download)
                }
                realm.refresh()
                DispatchQueue.global(qos: .userInteractive).async {
                    completion(id)
                }
            }
        }
    }
    
    func removeDownload(with index: Int, completion: @escaping () -> ()) {
        realmQueue.async {
            let download = self.downloads[index]
            self.removeDownload(download) {
                completion()
            }
        }
    }
    
    func removeDownload(with id: String, completion: @escaping () -> ()) {
        realmQueue.async {
            guard let download = self.download(with: id) else {
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            self.removeDownload(download) {
                completion()
            }
        }
    }
    
    func removeDownload(_ download: SongDownload, completion: @escaping () -> ()) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(download)
        }
        DispatchQueue.main.async {
            try! Realm().refresh()
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
    
    func download(with id: String, completion: @escaping (SongDownload?) -> ()) {
        realmQueue.async {
            guard let download = self.download(with: id) else {
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
    
    func indexForDownload(with id: String, completion: @escaping (Int?) -> ()) {
        realmQueue.async {
            let index = self.downloads.index(matching: "id = %@", id)
            DispatchQueue.main.async {
                completion(index)
            }
        }
    }
    
    func clearResumeDataForDownload(with id: String, completion: @escaping () -> ()) {
        realmQueue.async {
            guard let download = self.download(with: id) else {
                return
            }
            download.clearResumeData()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func setupResumeData(_ data: Data?, forDownloadWith id: String, completion: @escaping () -> ()) {
        realmQueue.async {
            guard let download = self.download(with: id) else {
                return
            }
            download.resumeData = data
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func setupStatus(_ status: DownloadStatus, forDownloadWith id: String, completion: @escaping () -> ()) {
        realmQueue.async {
            guard let download = self.download(with: id) else {
                return
            }
            download.status = status
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func setupProgress(_ progress: Progress, forDownloadWith id: String) {
        realmQueue.async {
            if let download = self.download(with: id) {
                download.progress = progress
            }
        }
    }
    
    func linkDownload(with id: String, to song: Song) {
        download(with: id) { download in
            let realm = try? Realm()
            try? realm?.write {
                download?.song = song
            }
        }
    }
    
    func clearFinishedDownloads(completion: @escaping () -> ()) {
        realmQueue.async {
            let realm = try? Realm()
            try? realm?.write {
                realm?.delete(self.finishedDownloads)
            }
            DispatchQueue.main.async {
                try! Realm().refresh()
                completion()
            }
        }
    }
    
    private func download(with id: String) -> SongDownload? {
        return try! Realm().object(ofType: SongDownload.self, forPrimaryKey: id)
    }
    
    
    
    
    
}
