//
//  SimpleWebViewController.swift
//  Credify
//
//  Created by Gioan Le on 21/07/2022.
//

import UIKit
import WebKit
import SafariServices

/// I create this class to show simple web page only. Don't effect with our logic 
class SimpleWebViewController: UIViewController {
    var maskBackgroud: UIView!
    
    var originalWebViewFrame: CGRect? = nil
    
    var webView: WKWebView!
    
    var url: URL!
    
    var webViewFrame: CGRect {
        get {
            let webViewFrame: CGRect
            
            if #available(iOS 11.0, *) {
                let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
                webViewFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: safeAreaFrame.size)
            } else {
                let viewFrame = view.frame
                webViewFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: viewFrame.size)
            }
            
            return webViewFrame
        }
    }
    
    var shouldShowNavBar: Bool {
        get {
            return true
        }
    }
    
    var shouldClearCache: Bool {
        get {
            return false
        }
    }
    
    static func instantiate(url: URL) -> SimpleWebViewController {
        let vc = SimpleWebViewController()
        vc.url = url
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingView.start(container: view)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        addMaskBackground()
        
        customizeNavBar(shoulShowNavBar: shouldShowNavBar)
            
        setupWebView()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title"  {
            title = webView.title ?? ""
        }
        
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
        }
    }
    
    func createWebView() -> WKWebView {
        let configuration = createWebViewConfiguration()
        
        let webView = WKWebView(frame: webViewFrame, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self

        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        webView.customUserAgent = AppState.shared.config?.userAgent
        // Disable preview to avoid white page
        webView.allowsLinkPreview = false
        
        return webView
    }
    
    
    // MARK: - Private functions
    
    private func createWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        // Needed for eKYC camera
        configuration.allowsInlineMediaPlayback = true
        
        // Disable zoom in
        configuration.userContentController.addUserScript(
            WKUserScript(
                source: WebViewUtils.scriptToDisableZoomIn,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )
        
        return configuration
    }
    
    private func setupWebView() {
        webView = createWebView()
        view.addSubview(webView)
        
        self.originalWebViewFrame = webView.frame
        
        // 26031: Housecare ios - SDK - styling issue
        // Position the WebView
        // Leading and Trailing
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Top and Bottom
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 0.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: webView.bottomAnchor, multiplier: 0.0)
            ])
        } else {
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0),
                bottomLayoutGuide.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 0)
            ])
        }
        
        guard let url = self.url else { return }
        
        if shouldClearCache {
            // 23274: Investigate caching issue on webview
            // Clear website data first for testing some bugs to make sure
            // that the bugs happen due to caching issue
            // If it fixed these bugs then we need to think about the improvement for caching.
            WKWebsiteDataStore.default().removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                modifiedSince: Date(timeIntervalSince1970: 0)
            ) {
                self.webView?.load(URLRequest(url: url))
            }
        } else {
            webView?.load(URLRequest(url: url))
        }
    }
    
    private func customizeNavBar(shoulShowNavBar: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
        if !shoulShowNavBar {
            navBar.isHidden = true
            return
        }
        
        navBar.backgroundColor = UIColor.white
        
        navBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
        ]
        
        navBar.tintColor = UIColor.black
        if #available(iOS 13.0, *) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "ic_back", in: Bundle.serviceX, with: nil),
                style: .plain,
                target: self,
                action: #selector(goBack)
            )
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "ic_back", in: Bundle.serviceX, compatibleWith: nil),
                style: .plain,
                target: self,
                action: #selector(goBack)
            )
        }
    }
    
    private func addMaskBackground() {
        maskBackgroud = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: 100
            )
        )
        maskBackgroud.backgroundColor = UIColor.white
        view.addSubview(maskBackgroud)
        
        // Position the mask background
        // Leading and Trailing
        NSLayoutConstraint.activate([
            maskBackgroud.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            maskBackgroud.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Top and Bottom
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                maskBackgroud.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 0.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: maskBackgroud.bottomAnchor, multiplier: 0.0)
            ])
        } else {
            NSLayoutConstraint.activate([
                maskBackgroud.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0),
                bottomLayoutGuide.topAnchor.constraint(equalTo: maskBackgroud.bottomAnchor, constant: 0)
            ])
        }
    }
    
    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
            return
        }
        
        close()
    }
    
    @objc private func close() {
        dismiss(animated: true){}
    }
}

extension SimpleWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message:
                 String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () ->
                 Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle:
                                                        .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) {_ in
            completionHandler()})
        
        present(alertController, animated: true)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            let vc = SFSafariViewController(url: url)
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = .overFullScreen
            present(nvc, animated: true)
            
            return nil
        }
        return nil
    }
}

extension SimpleWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingView.stop()
    }
}
