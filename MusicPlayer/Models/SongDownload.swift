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
    @objc private(set) dynamic var id = UUID().uuidString
    
    @objc private dynamic var downloadUrl = ""
    @objc private dynamic var totalByteCount: Int64 = 0
    @objc private dynamic var downloadedByteCount: Int64 = 0
    @objc private dynamic var downloadStatus = DownloadStatus.preparing.rawValue
    
    @objc private dynamic var resumeDataSubpath: String?
    
    @objc dynamic var song: Song?
    
    var url: URL {
        return URL(string: downloadUrl)!
    }
    
    var totalSize: String {
        return ByteCountFormatter.string(fromByteCount: totalByteCount, countStyle: .file).capitalized
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
            let pathComponent = UUID().uuidString + ".txt"
            let resumeDataUrl = cacheUrl.appendingPathComponent(pathComponent)
            
            do {
                try data.write(to: resumeDataUrl)
                let realm = try Realm()
                try realm.write {
                    resumeDataSubpath = pathComponent
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
            if newValue == .downloaded {
                clearResumeData()
            }
        }
    }
    
    convenience init(url: URL, title: String) {
        self.init()
        self.title = title
        self.downloadUrl = url.absoluteString
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func clearResumeData() {
        guard let path = resumeDataPath else {
            return
        }
        let realm = try? Realm()
        try? realm?.write {
            resumeDataSubpath = nil
        }
        realm?.refresh()
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
    }
    
    private var resumeDataPath: String? {
        guard let subpath = resumeDataSubpath else {
            return nil
        }
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let resumeDataUrl = documentsUrl.appendingPathComponent("DownloadsCache").appendingPathComponent(subpath)
        return resumeDataUrl.path
    }
}

enum DownloadStatus: String {
    
    case paused = "Paused"
    case failed = "Failed"
    case preparing = "Preparing"
    case downloaded = "Downloaded"
    case downloading = "Downloading"
}


