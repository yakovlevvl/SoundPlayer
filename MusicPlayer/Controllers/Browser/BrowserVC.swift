//
//  BrowserVC.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 22.01.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import WebKit

final class BrowserVC: UIViewController {
    
    private let webView = WKWebView()
    
    private let topBar = BrowserTopBar()
    private let toolBar = BrowserToolBar()
    
    private var historyVC: BrowserHistoryVC?
    
    private let progressView: ProgressView = {
        let view = ProgressView()
        view.autoreset = true
        view.frame.size.height = 3
        view.progressColor = UIColor(hex: "0080FF")
        return view
    }()
    
    private var alertView: AlertView?
    
    weak var delegate: BrowserDelegate?
    
    weak var downloadDelegate: BrowserDownloadDelegate?
    
    private var downloadService: DownloadService!

    private let downloadsManager = DownloadsManager()
    
    private let bookmarksManager = BookmarksManager()
    
    private let historyManager = BrowserHistoryManager()
    
    private let transitionManager = VerticalTransitionManager()
    
    private let musicFormats = ["mp3", "aac", "aiff", "wav", "alac"]
    
    var titleObservation: NSKeyValueObservation?
    var goBackObservation: NSKeyValueObservation?
    var loadingObservation: NSKeyValueObservation?
    var progressObservation: NSKeyValueObservation?
    var goForwardObservation: NSKeyValueObservation?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        downloadService = DownloadService.shared(delegate: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SettingsManager.browserNeedReset {
            SettingsManager.browserNeedReset = false
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        view.addSubview(toolBar)
        view.addSubview(progressView)
        view.insertSubview(webView, at: 0)
        
        topBar.delegate = self
        toolBar.delegate = self
        
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInset.top = topBar.frame.height
        webView.scrollView.scrollIndicatorInsets.top = topBar.frame.height
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_2_5 like Mac OS X) AppleWebKit/604.5.6 (KHTML, like Gecko) Version/11.0 Mobile/15D60 Safari/604.1"
        
        toolBar.isForwardButtonEnabled = false
        toolBar.isBackButtonEnabled = false
        
        setupObservations()
        
        layoutViews()
        
        loadLastUrl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveLastUrl), name: .UIApplicationWillTerminate, object: nil)
    }
    
    private func layoutViews() {
        toolBar.frame.origin.x = 0
        topBar.frame.origin = .zero
        if currentDevice == .iPhoneX {
            if #available(iOS 11.0, *) {
                webView.scrollView.contentInsetAdjustmentBehavior = .never
                topBar.frame.origin.y = UIProperties.iPhoneXTopInset
            }
        }
        
        topBar.frame.size = CGSize(width: view.frame.width, height: 62)
        toolBar.frame.size = CGSize(width: view.frame.width, height: 62)
        
        webView.frame.origin = topBar.frame.origin
        webView.frame.size.width = view.frame.width
        
        let bottomInset: CGFloat = 16
        
        if currentDevice == .iPhoneX {
            toolBar.frame.origin.y = view.frame.height - toolBar.frame.height - bottomInset
            webView.frame.size.height = view.frame.height - topBar.frame.minY - bottomInset
        } else {
            toolBar.frame.origin.y = view.frame.height - toolBar.frame.height
            webView.frame.size.height = view.frame.height - topBar.frame.minY
        }

        progressView.frame.origin.x = 0
        progressView.frame.size.width = view.frame.width
        progressView.frame.origin.y = currentDevice == .iPhoneX ? topBar.frame.maxY - progressView.frame.height : topBar.frame.origin.y
    }
    
    private func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc private func saveLastUrl() {
        UserDefaults.standard.set(webView.url, forKey: "browserLastUrl")
    }
    
    private func loadLastUrl() {
        if let url = UserDefaults.standard.url(forKey: UserDefaultsKeys.browserLastUrl) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            setupAlertView()
        }
    }
    
    private func setupAlertView() {
        alertView = AlertView(frame: webView.bounds)
        alertView!.text = "Search or enter website name"
        alertView!.icon = UIImage(named: "BrowserSearchIconBig")!
        webView.addSubview(alertView!)
    }
    
    private func showAlertView() {
        if alertView != nil {
            alertView!.alpha = 1
        }
    }
    
    private func hideAlertView() {
        if alertView != nil {
            alertView!.alpha = 0
        }
    }
    
    private func removeAlertView() {
        if alertView != nil {
            alertView!.removeFromSuperview()
            alertView = nil
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
        let saveAction = Action(title: "Save", type: .normal) { 
            let songName = alertVC.textFieldText!
            self.downloadSong(with: url, with: songName)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(saveAction)
        alertVC.present()
    }
    
    private func downloadSong(with url: URL, with name: String) {
        if downloadService.isDownloadExist(with: url) { return }
        downloadsManager.addDownload(with: url, title: name) { downloadId in
            self.downloadService.startDownload(with: url, title: name, id: downloadId)
        }
    }
    
    private func removeHistoryVC() {
        UIView.animate(0.2, animation: {
            self.historyVC?.view.alpha = 0
        }, completion: { _ in
            self.historyVC?.removeFromParent()
            self.historyVC = nil
        })
    }
    
    private func setupHistoryVC() {
        historyVC = BrowserHistoryVC()
        historyVC!.delegate = self
        historyVC!.historyManager = historyManager
        addChildController(historyVC!)
        historyVC!.view.frame.size.width = view.frame.width
        historyVC!.view.frame.origin = CGPoint(x: 0, y: topBar.frame.maxY)
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue!
        if frame.origin.y >= view.frame.height {
            showAlertView()
            removeHistoryVC()
            removeKeyboardObserver()
            return
        }
        hideAlertView()
        UIView.performWithoutAnimation {
            print("~keyboardWillChangeFrame~")
            if historyVC == nil {
               setupHistoryVC()
            }
            if historyVC != nil {
                historyVC!.view.frame.size.height = frame.origin.y - topBar.frame.maxY
            }
        }
    }
    
    private func updateHistory(with url: URL?, title: String?) {
        guard let url = url else { return }
        var title = title
        if title == nil || title!.isEmpty {
            title = url.absoluteString
        }
        historyManager.addItem(with: url, title: title!)
    }
    
    private func load(with url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("Browser deinit")
    }
    
}

extension BrowserVC: DownloadServiceDelegate {
    
    func downloadServiceStartedDownloading(with url: URL, title: String?, id: String?) {
        downloadsManager.setupStatus(.downloading, forDownloadWith: id!) {
            self.downloadDelegate?.browserStartedDownload(with: id!)
        }
    }
    
    func downloadServicePreparingToResumeDownloading(with url: URL, title: String?, id: String?) {
        downloadsManager.setupStatus(.preparing, forDownloadWith: id!) {
            self.downloadDelegate?.browserResumedDownload(with: id!)
        }
    }
    
    func downloadServiceFailedSavingFileFromDownload(with url: URL, title: String?, id: String?) {
        downloadsManager.setupStatus(.failed, forDownloadWith: id!) {
            self.downloadDelegate?.browserFailedDownload(with: id!)
        }
    }
    
    func downloadServiceFailedDownloading(with url: URL, resumeData: Data?, title: String?, id: String?) {
        downloadsManager.setupStatus(.failed, forDownloadWith: id!) {
            self.downloadsManager.setupResumeData(resumeData, forDownloadWith: id!) {
                self.downloadDelegate?.browserFailedDownload(with: id!)
            }
        }
    }
    
    func downloadServicePausedDownloading(with url: URL, resumeData: Data?, title: String?, id: String?) {
        downloadsManager.setupStatus(.paused, forDownloadWith: id!) {
            self.downloadsManager.setupResumeData(resumeData, forDownloadWith: id!) {
                self.downloadDelegate?.browserPausedDownload(with: id!)
            }
        }
    }
    
    func downloadServiceFinishedDownloading(with url: URL, to location: URL, title: String?, id: String?) {
        downloadsManager.setupStatus(.downloaded, forDownloadWith: id!) {
            self.downloadDelegate?.browserFinishedDownload(with: id!)
            Library.main.addSong(with: location, title: title!) { song in
                self.downloadsManager.linkDownload(with: id!, to: song)
                self.delegate?.browserDownloadedSong()
                NotificationService.main.presentNotificationForDownloadedSong(with: title!, url: location)
                if SettingsManager.spotlightIsEnabled {
                    SpotlightManager.indexSong(song)
                }
            }
        }
    }
    
    func downloadServiceDownloadedData(from url: URL, with byteCount: Int64, of totalByteCount: Int64, title: String?, id: String?) {
        let progress = Progress(totalByteCount: totalByteCount, downloadedByteCount: byteCount)
        downloadsManager.setupProgress(progress, forDownloadWith: id!)
        downloadDelegate?.browserUpdatedDownload(with: id!, with: progress)
    }
}

extension BrowserVC: BrowserToolBarDelegate {
    
    func tapBookmarksButton() {
        if let url = webView.url {
            showActionsForBookmarks(currentUrl: url)
        } else {
            showBookmarks()
        }
    }
    
    private func showBookmarks() {
        let bookmarksVC = BookmarksVC()
        transitionManager.cornerRadius = currentDevice == .iPhoneX ? 40 : 8
        bookmarksVC.transitioningDelegate = transitionManager
        bookmarksVC.bookmarksManager = bookmarksManager
        bookmarksVC.delegate = self
        present(bookmarksVC, animated: true)
    }
    
    private func showActionsForBookmarks(currentUrl: URL) {
        let actionSheet = RoundActionSheet()
        let addAction = Action(title: "Add to Bookmarks", type: .normal) {
            self.showAlertViewForSaveBookmark(with: currentUrl)
        }
        let showAction = Action(title: "Show Bookmarks", type: .normal) {
            self.showBookmarks()
        }
        actionSheet.addAction(addAction)
        actionSheet.addAction(showAction)
        actionSheet.present()
    }
    
    private func showAlertViewForSaveBookmark(with url: URL) {
        let alertVC = AlertController(message: "New Bookmark")
        alertVC.includeTextField = true
        alertVC.allowEmptyTextField = false
        alertVC.showClearButton = true
        alertVC.textFieldPlaceholder = "Name"
        alertVC.textFieldText = webView.title ?? ""
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        let cancelAction = Action(title: "Cancel", type: .cancel)
        let saveAction = Action(title: "Save", type: .normal) { 
            let bookmarkName = alertVC.textFieldText!
            self.addBookmark(with: url, title: bookmarkName)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(saveAction)
        alertVC.present()
    }
    
    private func addBookmark(with url: URL, title: String) {
        bookmarksManager.addBookmark(with: url, title: title) {}
    }
    
    func tapDownloadsButton() {
        let downloadsVC = DownloadsVC()
        transitionManager.cornerRadius = currentDevice == .iPhoneX ? 40 : 8
        downloadsVC.transitioningDelegate = transitionManager
        downloadsVC.downloadsManager = downloadsManager
        downloadDelegate = downloadsVC
        present(downloadsVC, animated: true)
    }
    
    func tapCloseButton() {
        dismiss(animated: true)
    }
    
    func tapBackButton() {
        webView.goBack()
    }
    
    func tapForwardButton() {
        webView.goForward()
    }
}

extension BrowserVC: BookmarksDelegate {
    
    func didTapBookmark(with url: URL) {
        load(with: url)
    }
}

extension BrowserVC: BrowserTopBarDelegate {
    
    func tapStopButton() {
        webView.stopLoading()
    }
    
    func tapReloadButton() {
        webView.stopLoading()
        if let url = webView.url {
            webView.load(URLRequest(url: url))
        }
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
        setupKeyboardObserver()
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
        showBars()
        removeAlertView()
        if topBar.keyboardIsShown {
            topBar.hideKeyboard()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateHistory(with: webView.url, title: webView.title)
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
        guard let response = navigationResponse.response as? HTTPURLResponse else {
            return decisionHandler(.allow)
        }
        if response.statusCode >= 400 {
            return decisionHandler(.allow)
        }
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: response.allHeaderFields as! [String : String], for: response.url!)
        for cookie in cookies {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {

    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail navigation")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == -999 { return }
        let alertVC = AlertController(message: "Browser cannot open the page because the server cannot be found")
        alertVC.font = UIFont(name: Fonts.general, size: 21)!
        alertVC.addAction(Action(title: "Okay", type: .cancel))
        alertVC.present()
        print(error.localizedDescription)
    }
    
    
}

extension BrowserVC: BrowserHistoryDelegate {
    
    func didTapClearButton() {
        historyManager.clearHistory {
            self.removeHistoryVC()
        }
    }
    
    func didSelectHistoryItem(with url: URL) {
        load(with: url)
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
            self.progressView.transform = .identity
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
            let topBarTranslation = currentDevice == .iPhoneX ? self.topBar.frame.height + UIProperties.iPhoneXTopInset : self.topBar.frame.height
            self.topBar.transform = CGAffineTransform(translationX: 0, y: -topBarTranslation)
            self.toolBar.transform = CGAffineTransform(translationX: 0, y: self.toolBar.frame.height)
            if currentDevice == .iPhoneX {
                self.progressView.transform = CGAffineTransform(translationX: 0, y: -self.topBar.frame.height)
            }
        }
    }
}

protocol BrowserDelegate: class {

    func browserDownloadedSong()
}

protocol BrowserDownloadDelegate: class {
    
    func browserFailedDownload(with id: String)
    
    func browserPausedDownload(with id: String)
    
    func browserStartedDownload(with id: String)
    
    func browserResumedDownload(with id: String)
    
    func browserFinishedDownload(with id: String)
    
    func browserCanceledDownload(with id: String)
    
    func browserUpdatedDownload(with id: String, with progress: Progress)

}

extension BrowserDownloadDelegate {
    
    func browserCanceledDownload(with id: String) {}
    
}





