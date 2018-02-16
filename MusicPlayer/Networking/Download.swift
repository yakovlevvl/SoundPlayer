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
    
    private var task: URLSessionDownloadTask
    
    var url: URL? {
        return task.originalRequest?.url
    }
    
    var title = "" {
        didSet {
            task.taskDescription = title
        }
    }
    
    init(task: URLSessionDownloadTask) {
        self.task = task
    }
    
    func start() {
        task.resume()
        isDownloading = true
    }
    
    func pause(completion: @escaping (Data?) -> ()) {
        isDownloading = false
        task.cancel { data in
            completion(data)
        }
    }
    
    func cancel() {
        task.cancel()
    }
    
}
