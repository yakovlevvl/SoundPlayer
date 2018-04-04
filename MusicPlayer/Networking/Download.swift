//
//  Download.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 01.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import Foundation

class Download {
    
    var isDownloading = false
    
    private let task: URLSessionDownloadTask
    
    var url: URL? {
        return task.url
    }
    
    var id: String? {
        get {
            return task.id
        }
        set {
            task.id = newValue
        }
    }
    
    var title: String? {
        get {
            return task.title
        }
        set {
            task.title = newValue
        }
    }
    
    init(task: URLSessionDownloadTask) {
        self.task = task
    }
    
    func start() {
        task.resume()
    }
    
    func cancel() {
        task.cancel()
    }
    
    func pause(completion: @escaping (Data?) -> ()) {
        task.cancel { data in
            completion(data)
        }
    }
}
