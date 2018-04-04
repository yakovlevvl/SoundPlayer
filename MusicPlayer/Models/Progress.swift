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
        return totalByteCount != 0 ? Double(downloadedByteCount)/Double(totalByteCount) : 0
    }
    
    var description: String {
        let totalSizeString = ByteCountFormatter.string(fromByteCount: totalByteCount, countStyle: .file).capitalized
        let downloadedSizeString = ByteCountFormatter.string(fromByteCount: downloadedByteCount, countStyle: .file).capitalized
        return "\(downloadedSizeString) of \(totalSizeString)"
    }
}
