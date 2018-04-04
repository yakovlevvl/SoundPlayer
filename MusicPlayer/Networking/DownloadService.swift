//
//  DownloadService.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 01.02.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

class DownloadService: NSObject {
    
    private var session: URLSession!
    
    private var downloads = [URL: Download]()
    
    private static var shared: DownloadService!
    
    weak var delegate: DownloadServiceDelegate?
    
    private init(delegate: DownloadServiceDelegate?) {
        super.init()
        self.delegate = delegate
        let sessionId = "com.download.MusicPlayer"
        let configuration = URLSessionConfiguration.background(withIdentifier: sessionId)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    static func shared(delegate: DownloadServiceDelegate? = nil) -> DownloadService {
        if shared == nil {
            shared = DownloadService(delegate: delegate)
        } else if delegate != nil {
            fatalError()
        }
        return shared
    }
    
    func startDownload(with url: URL, title: String? = nil, id: String? = nil) {
        guard downloads[url] == nil else { return }
        let task = session.downloadTask(with: url)
        let download = Download(task: task)
        download.title = title
        download.id = id
        download.start()
        downloads[url] = download
    }
    
    func pauseDownload(with url: URL) {
        guard let download = downloads[url] else { return }
        if download.isDownloading {
            download.pause { resumeData in
                self.delegate?.downloadServicePausedDownloading(with: url, resumeData: resumeData,
                    title: download.title, id: download.id)
            }
        }
    }
    
    func resumeDownload(with url: URL, resumeData: Data?, title: String? = nil, id: String? = nil) {
        guard downloads[url] == nil else { return }
        delegate?.downloadServicePreparingToResumeDownloading(with: url, title: title, id: id)
        var task: URLSessionDownloadTask!
        if isValidResumeData(resumeData) {
            task = session.downloadTask(withResumeData: resumeData!)
        } else {
            task = session.downloadTask(with: url)
        }
        let download = Download(task: task)
        download.title = title
        download.id = id
        download.start()
        downloads[url] = download
    }
    
    func cancelDownload(with url: URL) {
        if let download = downloads[url] {
            download.cancel()
            delegate?.downloadServiceCanceledDownloading(with: url, title: download.title, id: download.id)
        }
    }
    
    func isDownloadExist(with url: URL) -> Bool {
        return downloads[url] != nil
    }
}

extension DownloadService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.url else { return }
        let title = downloadTask.title
        let id = downloadTask.id
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode), fileExists(location.path) else {
                delegate?.downloadServiceFailedDownloading(with: url, resumeData: nil, title: title, id: id)
                return
        }
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let musicUrl = documentsUrl.appendingPathComponent("Music", isDirectory: true)
        if !fileManager.directoryExists(musicUrl.path) {
            try! fileManager.createDirectory(atPath: musicUrl.path, withIntermediateDirectories: true)
        }
        var fileUrl = musicUrl.appendingPathComponent(url.lastPathComponent)
        fileUrl = fileManager.changeUrlIfExists(fileUrl)
        do {
            try fileManager.moveItem(at: location, to: fileUrl)
            delegate?.downloadServiceFinishedDownloading(with: url, to: fileUrl, title: title, id: id)
        } catch {
            delegate?.downloadServiceFailedSavingFileFromDownload(with: url, title: title, id: id)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.url else { return }
        guard let download = downloads[url] else { return }
        let title = download.title
        let id = download.id
        if !download.isDownloading {
            download.isDownloading = true
            DispatchQueue.global().async {
                self.delegate?.downloadServiceStartedDownloading(with: url, title: title, id: id)
            }
        }
        delegate?.downloadServiceDownloadedData(from: url, with: totalBytesWritten, of: totalBytesExpectedToWrite, title: title, id: id)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(error == nil ? "downloadCompleted" : "downloadCompletedWithError: \(error!.localizedDescription)")
        
        let downloadTask = task as! URLSessionDownloadTask
        guard let url = downloadTask.url else { return }
        
        downloads[url] = nil
        
        guard let error = error as NSError? else { return }
        
        let title = downloadTask.title
        let id = downloadTask.id
        
        var resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
        
        if !isValidResumeData(resumeData) {
            resumeData = nil
        }
        
        if (error.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey]
            as? NSNumber)?.intValue != nil {
            resumeDownload(with: url, resumeData: resumeData, title: title, id: id)
        } else {
            guard error.code != NSURLErrorCancelled else { return }
            delegate?.downloadServiceFailedDownloading(with: url, resumeData: resumeData, title: title, id: id)
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }
}

extension DownloadService: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundCompletionHandler else { return }
            appDelegate.backgroundCompletionHandler = nil
            completionHandler()
        }
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

protocol DownloadServiceDelegate: class {
    
    func downloadServiceStartedDownloading(with url: URL, title: String?, id: String?)
    func downloadServiceCanceledDownloading(with url: URL, title: String?, id: String?)
    func downloadServicePreparingToResumeDownloading(with url: URL, title: String?, id: String?)
    func downloadServiceFailedSavingFileFromDownload(with url: URL, title: String?, id: String?)
    func downloadServiceFailedDownloading(with url: URL, resumeData: Data?, title: String?, id: String?)
    func downloadServicePausedDownloading(with url: URL, resumeData: Data?, title: String?, id: String?)
    func downloadServiceFinishedDownloading(with url: URL, to location: URL, title: String?, id: String?)
    func downloadServiceDownloadedData(from url: URL, with byteCount: Int64, of totalByteCount: Int64, title: String?, id: String?)
}

extension DownloadServiceDelegate {
    
    func downloadServiceStartedDownloading(with url: URL, title: String?, id: String?) {}
    func downloadServiceCanceledDownloading(with url: URL, title: String?, id: String?) {}
    func downloadServicePreparingToResumeDownloading(with url: URL, title: String?, id: String?) {}
    func downloadServiceFailedSavingFileFromDownload(with url: URL, title: String?, id: String?) {}
    func downloadServiceFailedDownloading(with url: URL, resumeData: Data?, title: String?, id: String?) {}
    func downloadServicePausedDownloading(with url: URL, resumeData: Data?, title: String?, id: String?) {}
    func downloadServiceFinishedDownloading(with url: URL, to location: URL, title: String?, id: String?) {}
    func downloadServiceDownloadedData(from url: URL, with byteCount: Int64, of totalByteCount: Int64, title: String?, id: String?) {}
}

