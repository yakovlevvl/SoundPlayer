//
//  SongDownload.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 03.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class SongDownload: Object {
    
    @objc private(set) dynamic var title = ""
    @objc private(set) dynamic var creationDate = Date()
    
    @objc private dynamic var downloadUrl = ""
    @objc private dynamic var totalByteCount: Int64 = 0
    @objc private dynamic var downloadedByteCount: Int64 = 0
    @objc private dynamic var downloadStatus = DownloadStatus.preparing.rawValue
    
    @objc private dynamic var resumeDataPath: String?
    
    @objc dynamic var song: Song?
    
    var url: URL {
        return URL(string: downloadUrl)!
    }
    
    var totalSize: String {
        return ByteCountFormatter.string(fromByteCount: totalByteCount, countStyle: .file)
    }
    
    var resumeData: Data? {
        get {
            guard let path = resumeDataPath else {
                return nil
            }
            return try? Data(contentsOf: URL(fileURLWithPath: path))
        }
        set {
            clearResumeData()
            guard let data = newValue else {
                return
            }
            let fileManager = FileManager.default
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let cacheUrl = documentsUrl.appendingPathComponent("DownloadsCache", isDirectory: true)
            if !fileManager.directoryExists(cacheUrl.path) {
                try! fileManager.createDirectory(atPath: cacheUrl.path, withIntermediateDirectories: true)
            }
            let resumeDataUrl = cacheUrl.appendingPathComponent(UUID().uuidString + ".txt")
            
            do {
                try data.write(to: resumeDataUrl)
                let realm = try Realm()
                try realm.write {
                    resumeDataPath = resumeDataUrl.path
                }
                realm.refresh()
            } catch {
                if fileManager.fileExists(atPath: resumeDataUrl.path) {
                    try? fileManager.removeItem(atPath: resumeDataUrl.path)
                }
            }
        }
    }

    var progress: Progress {
        get {
            return Progress(totalByteCount: totalByteCount, downloadedByteCount: downloadedByteCount)
        }
        set {
            let realm = try? Realm()
            try? realm?.write {
                totalByteCount = newValue.totalByteCount
                downloadedByteCount = newValue.downloadedByteCount
            }
            realm?.refresh()
        }
    }
    
    var status: DownloadStatus {
        get {
            return DownloadStatus(rawValue: downloadStatus)!
        }
        set {
            let realm = try? Realm()
            try? realm?.write {
                downloadStatus = newValue.rawValue
            }
            realm?.refresh()
            /////
            print(downloadStatus)
        }
    }
    
    convenience init(url: URL, title: String) {
        self.init()
        self.title = title
        self.downloadUrl = url.absoluteString
    }
    
    func clearResumeData() {
        guard let path = resumeDataPath else {
            return
        }
        let realm = try? Realm()
        try? realm?.write {
            resumeDataPath = nil
        }
        realm?.refresh()
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
    }
    
}
