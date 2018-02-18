//
//  BrowserVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import WebKit

final class BrowserVC: UIViewController {
    
    private let webView = WKWebView()
    
    private let topBar = BrowserTopBar()
    private let toolBar = BrowserToolBar()
    
    private let progressView: ProgressView = {
        let view = ProgressView()
        view.frame.size.height = 3
        view.progressColor = UIColor(hex: "0080FF")
        return view
    }()
    
    private let downloadService = DownloadService.shared

    private let downloadsManager = DownloadsManager()
    
    private let musicFormats = ["mp3", "aac", "aiff", "wav", "alac"]
    
    var progressObservation: NSKeyValueObservation?
    var loadingObservation: NSKeyValueObservation?
    var titleObservation: NSKeyValueObservation?
    var goBackObservation: NSKeyValueObservation?
    var goForwardObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        topBar.frame.origin = .zero
        topBar.frame.size = CGSize(width: view.frame.width, height: 62)
        
        toolBar.frame.origin.x = 0
        toolBar.frame.size = CGSize(width: view.frame.width, height: 62)
        toolBar.frame.origin.y = view.frame.height - toolBar.frame.height
        
        topBar.delegate = self
        toolBar.delegate = self
        
        webView.frame = view.frame
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInset.top = topBar.frame.height
        webView.scrollView.scrollIndicatorInsets.top = topBar.frame.height
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_2_5 like Mac OS X) AppleWebKit/604.5.6 (KHTML, like Gecko) Version/11.0 Mobile/15D60 Safari/604.1"
        
        progressView.frame.size.width = view.frame.width
        
        view.addSubview(topBar)
        view.addSubview(toolBar)
        view.addSubview(progressView)
        view.insertSubview(webView, at: 0)
        
        toolBar.isBackButtonEnabled = false
        toolBar.isForwardButtonEnabled = false
        
        setupObservations()
        
        loadLastUrl()
        
        //let queue = DispatchQueue(label: "realm")
        
        //queue.async {
            //self.downloadsManager = DownloadsManager()
            //self.downloadsManager.queue = queue
        //}
        
        downloadService.delegate.add(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveLastUrl), name: .UIApplicationWillTerminate, object: nil)
    }
    
    @objc private func saveLastUrl() {
        UserDefaults.standard.set(webView.url, forKey: "browserLastUrl")
    }
    
    private func loadLastUrl() {
        if let url = UserDefaults.standard.url(forKey: "browserLastUrl") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func setupObservations() {
        goBackObservation = webView.observe(\.canGoBack) { [unowned self] webView, _ in
            self.toolBar.isBackButtonEnabled = webView.canGoBack
        }
        goForwardObservation = webView.observe(\.canGoForward) { [unowned self] webView, _ in
            self.toolBar.isForwardButtonEnabled = webView.canGoForward
        }
        progressObservation = webView.observe(\.estimatedProgress) { [unowned self] webView, _ in
            self.progressView.progress = webView.estimatedProgress
        }
        loadingObservation = webView.observe(\.isLoading) { [unowned self] webView, _ in
            self.loadStateChanged()
        }
        titleObservation = webView.observe(\.title) { [unowned self] webView, _ in
            self.setupTitle(webView.title)
        }
    }
    
    private func loadStateChanged() {
        if webView.isLoading {
            self.topBar.showStopButton()
        } else {
            self.topBar.showReloadButton()
        }
    }
    
    private func setupTitle(_ title: String?) {
        if let title = title?.trimmingCharacters(in: .whitespaces), !title.isEmpty {
            self.topBar.searchFieldText = title
        }
    }
    
    private func showAlertViewForSaveSong(with url: URL) {
        let alertVC = AlertController(message: "Save Song")
        alertVC.includeTextField = true
        alertVC.allowEmptyTextField = false
        alertVC.showClearButton = true
        alertVC.textFieldPlaceholder = "Name"
        alertVC.textFieldText = url.lastPathComponent
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let saveAction = Action(title: "Save", type: .normal) { _ in
            let songName = alertVC.textFieldText!
            self.downloadSong(with: url, with: songName)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(saveAction)
        alertVC.present()
    }
    
    private func downloadSong(with url: URL, with name: String) {
        let download = SongDownload(url: url, title: name)
        downloadsManager.addDownload(download) {
            self.downloadService.startDownload(with: url, title: name)
        }
        print("startDownloadWithUrl *** \(download.url) ***")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension BrowserVC: DownloadServiceDelegate {
    
    func downloadServiceFailedDownloading(with url: URL) {
        print("delegate: downloadManagerFailedDownloading")
        downloadsManager.setupStatus(.failed, forDownloadWith: url)
    }
    
    func downloadServiceFinishedDownloading(to location: URL, with url: URL, title: String) {
        downloadsManager.setupStatus(.downloaded, forDownloadWith: url)
        let song = Song(url: location)
        song.title = title
        Library.main.addSong(song)
        print("delegate: downloadManagerFinishedDownloading")
    }
    
    func downloadServiceDownloadedData(from url: URL, with byteCount: Int64, of totalByteCount: Int64) {
        let progress = Progress(totalByteCount: totalByteCount, downloadedByteCount: byteCount)
        downloadsManager.setupProgress(progress, forDownloadWith: url)
    }
    
}

extension BrowserVC: BrowserToolBarDelegate {
    
    func tapBookmarksButton() {
        
    }
    
    func tapDownloadsButton() {
        let downloadsVC = DownloadsVC()
        downloadsVC.downloadsManager = downloadsManager
        present(downloadsVC, animated: true)
    }
    
    func tapCloseButton() {
        
    }
    
    func tapBackButton() {
        webView.goBack()
    }
    
    func tapForwardButton() {
        webView.goForward()
    }
    
}

extension BrowserVC: BrowserTopBarDelegate {
    
    func tapStopButton() {
        webView.stopLoading()
    }
    
    func tapReloadButton() {
        webView.stopLoading()
        webView.load(URLRequest(url: webView.url!))
    }
    
    func searchFieldShouldReturn(with text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        topBar.hideKeyboard()
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        guard matches.isEmpty else {
            var urlString = text
            guard let components = URLComponents(string: text) else {
                let alertVC = AlertController(message: "Browser cannot open the page because the address is invalid")
                alertVC.addAction(Action(title: "Okay", type: .cancel))
                alertVC.present()
                return false
            }
            if components.scheme == nil {
                urlString = "https://\(urlString)"
            }
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL(string: urlString)!
            webView.load(URLRequest(url: url))
            return true
        }
        
        let searchText = text.replacingOccurrences(of: " ", with: "+", options: .literal)
        let urlString = "https://google.com/search?q=\(searchText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
        return true
    }
    
    func searchFieldDidBeginEditing() {
        if let url = webView.url?.absoluteString {
            topBar.searchFieldText = url.removingPercentEncoding ?? url
        }
    }
    
    func cancelSearchFieldEditing() {
        if webView.url == nil {
            topBar.searchFieldText = ""
        } else {
            topBar.searchFieldText = webView.title ?? ""
        }
    }

    func shouldShowLoadControlButton() -> Bool {
        return webView.url != nil
    }
}

extension BrowserVC: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if topBar.keyboardIsShown {
            topBar.hideKeyboard()
        }
        showBars()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showBars()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType == .linkActivated else {
            return decisionHandler(.allow)
        }
        guard let url = navigationAction.request.url else {
            return decisionHandler(.allow)
        }
        let pathExtension = url.pathExtension.lowercased()
        guard !pathExtension.isEmpty else {
            return decisionHandler(.allow)
        }
        guard musicFormats.contains(pathExtension) else {
            decisionHandler(.allow)
            return print("no song link")
        }
        print(url)
        showAlertViewForSaveSong(with: url)
        decisionHandler(.cancel)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let response = navigationResponse.response as! HTTPURLResponse
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: response.allHeaderFields as! [String : String], for: response.url!)
        for cookie in cookies {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail navigation")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alertVC = AlertController(message: "Browser cannot open the page because the server cannot be found")
        alertVC.addAction(Action(title: "Okay", type: .cancel))
        alertVC.present()
        print(error.localizedDescription)
    }
    
}

extension BrowserVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.contentSize.height > scrollView.frame.height, !topBar.keyboardIsShown else {
            return showBars()
        }
        if scrollView.panGestureRecognizer.velocity(in: scrollView.superview).y < 0 {
            hideBars()
        } else {
            showBars()
        }
    }
    
    private func showBars() {
        UIView.animate(0.24, options: [.allowUserInteraction, .curveEaseOut]) {
            self.topBar.transform = .identity
            self.toolBar.transform = .identity
            self.webView.scrollView.contentInset.top = self.topBar.frame.height
            self.webView.scrollView.contentInset.bottom = self.toolBar.frame.height
            self.webView.scrollView.scrollIndicatorInsets.top = self.topBar.frame.height
            self.webView.scrollView.scrollIndicatorInsets.bottom = self.toolBar.frame.height
        }
    }
    
    private func hideBars() {
        UIView.animate(0.24, options: [.allowUserInteraction, .curveEaseOut]) {
            self.webView.scrollView.contentInset.top = 0
            self.webView.scrollView.contentInset.bottom = 0
            self.webView.scrollView.scrollIndicatorInsets.top = 0
            self.webView.scrollView.scrollIndicatorInsets.bottom = 0
            self.topBar.transform = CGAffineTransform(translationX: 0, y: -self.topBar.frame.height)
            self.toolBar.transform = CGAffineTransform(translationX: 0, y: self.toolBar.frame.height)
        }
    }
}



