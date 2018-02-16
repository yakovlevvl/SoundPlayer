//
//  SongDownload.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 03.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import RealmSwift

class SongDownload: Object {
    
    @objc dynamic var title = ""
    @objc dynamic var totalByteCount: Int64 = 0
    @objc dynamic var downloadedByteCount: Int64 = 0
    @objc dynamic var creationDate = Date()
    @objc private dynamic var downloadUrl = ""
    @objc private dynamic var downloadStatus = DownloadStatus.preparing.rawValue
    
    //@objc dynamic var resumeDataPath: String?
    
    @objc dynamic var resumeData: Data?
    
    @objc dynamic var song: Song?
    
    var progress: Progress {
        get {
            return Progress(totalByteCount: totalByteCount, downloadedByteCount: downloadedByteCount)
        }
        set {
            try! Realm().write {
                totalByteCount = newValue.totalByteCount
                downloadedByteCount = newValue.downloadedByteCount
            }
        }
    }
    
    var status: DownloadStatus {
        get {
            return DownloadStatus(rawValue: downloadStatus)!
        }
        set {
            try! Realm().write {
                downloadStatus = status.rawValue
            }
        }
    }
    
    var url: URL {
        get {
            return URL(string: downloadUrl)!
        }
        set {
            downloadUrl = newValue.absoluteString
        }
    }
    
    var totalSize: String {
        return ByteCountFormatter.string(fromByteCount: totalByteCount, countStyle: .file)
    }
    
    
    
    
}
