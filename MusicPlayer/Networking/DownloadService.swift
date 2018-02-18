//
//  DownloadService.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 01.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import Foundation

class DownloadService: NSObject {
    
    static let shared = DownloadService()
    
    private var downloads = [URL: Download]()
    
    var delegate = MulticastDelegate<DownloadServiceDelegate>()
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: sessionId)
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    private let sessionId = "com.download.MusicPlayer"
    
    var backgroundCompletionHandler: (() -> ())?
    
    private override init() {}
    
    func startDownload(with url: URL, title: String) {
        guard downloads[url] == nil else { return }
        let task = session.downloadTask(with: url)
        let download = Download(task: task)
        download.title = title
        download.start()
        downloads[url] = download
        delegate.invoke {
            $0.downloadServiceStartedDownloading(with: url, title: title)
        }
    }
    
    func pauseDownload(with url: URL) {
        guard let download = downloads[url] else { return }
        if download.isDownloading {
            download.pause { data in
                self.delegate.invoke {
                    $0.downloadServicePausedDownloading(with: url, resumeData: data, title: download.title)
                }
            }
        }
    }
    
    func resumeDownload(with url: URL, resumeData: Data?, title: String) {
        var task: URLSessionDownloadTask!
        if isValidResumeData(resumeData) {
            task = session.downloadTask(withResumeData: resumeData!)
        } else {
            task = session.downloadTask(with: url)
        }
        let download = Download(task: task)
        download.title = title
        download.start()
        downloads[url] = download
        delegate.invoke {
            $0.downloadServiceResumedDownloading(with: url)
        }
    }
    
    func cancelDownload(with url: URL) {
        if let download = downloads[url] {
            download.cancel()
            delegate.invoke {
                $0.downloadServiceCanceledDownloading(with: url)
            }
        }
    }
    
}

extension DownloadService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url else { return }
        guard let title = downloads[url]?.title else { return }
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode), fileExists(location.path) else {
                delegate.invoke {
                    $0.downloadServiceFailedSavingFile(with: url)
                }
                return print("finishedDownloadingWithError")
        }
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicUrl = documentsUrl.appendingPathComponent("Music", isDirectory: true)
        if !fileManager.directoryExists(musicUrl.path) {
            try! fileManager.createDirectory(atPath: musicUrl.path, withIntermediateDirectories: true)
        }
        var destinationUrl = musicUrl.appendingPathComponent(url.lastPathComponent)
        
        var index = 1
        while fileExists(destinationUrl.path) {
            let url = destinationUrl
            var pathComponent = url.deletingPathExtension().lastPathComponent
            pathComponent += "\(index)"
            destinationUrl = destinationUrl.deletingLastPathComponent().appendingPathComponent(pathComponent).appendingPathExtension(destinationUrl.pathExtension)
            index += 1
        }
        print(location.absoluteString)
        do {
            try fileManager.moveItem(at: location, to: destinationUrl)
            DispatchQueue.main.async {
                self.delegate.invoke {
                    print("%%%%%%invoke delegate: \($0)")
                    $0.downloadServiceFinishedDownloading(to: destinationUrl, with: url, title: title)
                }
            }
            
            print("finishedDownloading")
            print("savedToUrl *** \(destinationUrl) ***")
        } catch let error as NSError {
            delegate.invoke {
                $0.downloadServiceFailedSavingFile(with: url)
            }
            print("Error while moving file to destinationUrl:", error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.originalRequest?.url else { return }
        delegate.invoke {
            $0.downloadServiceDownloadedData(from: url, with: totalBytesWritten, of: totalBytesExpectedToWrite)
        }
        print("downloaded \(totalBytesWritten)b of \(totalBytesExpectedToWrite)b")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(error == nil ? "downloadCompleted" : "downloadCompletedWithError: \(error!.localizedDescription)")
        
        guard let url = task.originalRequest?.url else { return }
        
        downloads[url] = nil
        
        guard let error = error as NSError? else { return }
        guard error.code != NSURLErrorCancelled else { return }
        
        let downloadTask = task as! URLSessionDownloadTask
        let title = downloadTask.taskDescription!
        
        var resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
        
        if !isValidResumeData(resumeData) {
            resumeData = nil
        }
        
        if (error.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey]
            as? NSNumber)?.intValue != nil {
            resumeDownload(with: url, resumeData: resumeData, title: title)
        } else {
            delegate.invoke {
                $0.downloadServiceFailedDownloading(with: url, resumeData: resumeData, title: title)
            }
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
}

extension DownloadService {
    
    private func isValidResumeData(_ resumeData: Data?) -> Bool {
        guard let filePath = getResumeDataFilePath(resumeData) else {
            return false
        }
        return fileExists(filePath)
    }
    
    private func getResumeDataFileUrl(_ resumeData: Data?) -> URL? {
        guard let filePath = getResumeDataFilePath(resumeData) else {
            return nil
        }
        return fileExists(filePath) ? URL(fileURLWithPath: filePath) : nil
    }
    
    private func fileExists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    private func getResumeDataFilePath(_ resumeData: Data?) -> String? {
        guard let resumeData = resumeData, !resumeData.isEmpty else {
            return nil
        }
        guard let resumeDictionary = (try? PropertyListSerialization.propertyList(from: resumeData,
            options: [], format: nil)) as? [String : Any] else {
            return nil
        }
        var filePath = resumeDictionary["NSURLSessionResumeInfoLocalPath"] as? String
        
        if filePath == nil || filePath!.isEmpty {
            filePath = NSTemporaryDirectory() + (resumeDictionary["NSURLSessionResumeInfoTempFileName"] as! String)
        }
        return filePath
    }
}

extension DownloadService: URLSessionDelegate {

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("urlSessionDidFinishEvents")
        if let completionHandler = backgroundCompletionHandler {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}

protocol DownloadServiceDelegate: class {

    func downloadServiceFailedSavingFile(with downloadUrl: URL)
    func downloadServiceFailedDownloading(with url: URL, resumeData: Data?, title: String)
    func downloadServiceResumedDownloading(with url: URL)
    func downloadServiceCanceledDownloading(with url: URL)
    func downloadServiceStartedDownloading(with url: URL, title: String)
    func downloadServiceFinishedDownloading(to location: URL, with url: URL, title: String)
    func downloadServicePausedDownloading(with url: URL, resumeData: Data?, title: String)
    func downloadServiceDownloadedData(from url: URL, with byteCount: Int64, of totalByteCount: Int64)

}

extension DownloadServiceDelegate {
    
    func downloadServiceFailedSavingFile(with downloadUrl: URL) {}
    func downloadServiceFailedDownloading(with url: URL, resumeData: Data?, title: String) {}
    func downloadServiceResumedDownloading(with url: URL) {}
    func downloadServiceCanceledDownloading(with url: URL) {}
    func downloadServiceStartedDownloading(with url: URL, title: String) {}
    func downloadServiceFinishedDownloading(to location: URL, with url: URL, title: String) {}
    func downloadServicePausedDownloading(with url: URL, resumeData: Data?, title: String) {}
    func downloadServiceDownloadedData(from url: URL, with byteCount: Int64, of totalByteCount: Int64) {}
    
}

enum DownloadStatus: String {
    
    case paused = "Paused"
    case failed = "Failed"
    case preparing = "Preparing"
    case downloaded = "Downloaded"
    case downloading = "Downloading"
}


