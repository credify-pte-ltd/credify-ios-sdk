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
    private var webView: WKWebView!
    
    private var url: URL!
    
    private var originalWebViewFrame: CGRect? = nil
    
    private var statusBarHeight: CGFloat {
        get {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            var statusBarHeight: CGFloat = 0
            if #available(iOS 13.0, *) {
                statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            }
            return statusBarHeight
        }
    }
    
    private var webViewHeight: CGFloat {
        get {
            // Have nav bar
            // let navAndStatusBarHeight = (navigationController?.navigationBar.frame.height ?? 0) + statusBarHeight
            // Have not nav bar
            let navAndStatusBarHeight = statusBarHeight
            
            let height: CGFloat
            
            if #available(iOS 11.0, *) {
                height = view.safeAreaLayoutGuide.layoutFrame.height - navAndStatusBarHeight
            } else {
                height = view.frame.height - navAndStatusBarHeight
            }
            
            return height
        }
    }
    
    private var paddingBottom: CGFloat {
        get {
            var padding: CGFloat = 0.0
            
            if #available(iOS 11.0, *) {
                padding = 8.0
            }
            
            return padding
        }
    }
    
    static func instantiate(url: URL) -> SimpleWebViewController {
        let vc = SimpleWebViewController()
        vc.url = url
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        customizeNavBar()
            
        setupWebView()
        
        LoadingView.start(container: view)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title"  {
            title = webView.title ?? ""
        }
        
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
        }
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
        
        // Update language
        if let languageScript = WebViewUtils.buildScriptToUpdateAppLanguage {
            configuration.userContentController.addUserScript(
                WKUserScript(
                    source: languageScript,
                    injectionTime: .atDocumentStart,
                    forMainFrameOnly: true
                )
            )
        }
        
        return configuration
    }
    
    private func setupWebView() {
        let configuration = createWebViewConfiguration()
        
        // 21840: UI issue - Long text and cut off button
        let webViewFrame: CGRect
        if #available(iOS 11.0, *) {
            let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
            webViewFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: safeAreaFrame.size)
        } else {
            let viewFrame = view.frame
            webViewFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: viewFrame.size)
        }
        
        webView = WKWebView(frame: webViewFrame,configuration: configuration)
        view.addSubview(webView)
        
        self.originalWebViewFrame = webView.frame
        
        // 23274: Investigate caching issue on webview
        // Clear website data first for testing some bugs to make sure
        // that the bugs happen due to caching issue
        // If it fixed these bugs then we need to think about the improvement for caching.
        guard let webView = self.webView else { return }
        guard let url = self.url else { return }

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
        
        webView.load(URLRequest(url: url))
        
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
    }
    
    private func customizeNavBar() {
        guard let navBar = navigationController?.navigationBar else {
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
