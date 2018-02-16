//
//  Progress.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 15.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import Foundation

struct Progress {
    
    var totalByteCount: Int64 = 0
    var downloadedByteCount: Int64 = 0
    
    var value: Double {
        return Double(downloadedByteCount)/Double(totalByteCount)
    }
    
    var description: String {
        let totalSizeString = ByteCountFormatter.string(fromByteCount: totalByteCount, countStyle: .file)
        let downloadedSizeString = ByteCountFormatter.string(fromByteCount: downloadedByteCount, countStyle: .file)
        return "\(downloadedSizeString) of \(totalSizeString)"
    }
}
