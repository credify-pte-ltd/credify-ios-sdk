//
//  WebViewController.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import UIKit
import WebKit
import SafariServices

class WebViewController: UIViewController {
    private var webView: WKWebView!
    
    private var url: URL!
    private var presenter: WebPresenterProtocol!
    
    static func instantiate(context: PassportContext) -> WebViewController {
        let vc = WebViewController()
        vc.url = context.url
        vc.presenter = WebPresenter(context: context)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 23462: Med247 app - Passport's background does not fit with height of Med247 app
        let theme = AppState.shared.config?.theme
        let themeColor = theme?.color
        view.backgroundColor = UIColor.fromHex(themeColor?.secondaryBackground ?? "#FFFFFF")
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        customizeNavBar()
            
        let configuration = WKWebViewConfiguration()
        let userController = WKUserContentController()
        
        presenter.receiveHandlers.forEach { handler in
            userController.add(self, name: handler.rawValue)
        }
        
        configuration.userContentController = userController
        configuration.allowsInlineMediaPlayback = true // Needed for eKYC camera
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
        
        // 23274: Investigate caching issue on webview
        // Clear website data first for testing some bugs to make sure
        // that the bugs happen due to caching issue
        // If it fixed these bugs then we need to think about the improvement for caching.
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date(timeIntervalSince1970: 0)
        ) {
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
            
            webView.load(URLRequest(url: url))
        }
        
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
        
        LoadingView.start(container: view)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title"  {
            title = webView.title ?? ""
        }
        
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
        }
        
        // Scroll the WKWebView once the page is changed
        if keyPath == #keyPath(WKWebView.url) {
            webView.scrollView.setContentOffset(CGPoint.zero, animated: true)
            
            let url = webView.url
            self.setBackButtonVisibility(isVisible: self.presenter.isBackButtonVisible(urlObj: url))
            self.setCloseButtonVisibility(isVisible: self.presenter.isCloseButtonVisible(urlObj: url))
        }
        
        if keyPath == #keyPath(WKWebView.canGoBack) ||
            keyPath == #keyPath(WKWebView.canGoForward) ||
            keyPath == #keyPath(WKWebView.url) ||
            keyPath == #keyPath(WKWebView.estimatedProgress){
            // There is no history
            if !webView.canGoBack {
                self.setBackButtonVisibility(isVisible: false)
                self.setCloseButtonVisibility(isVisible: true)
                return
            }
        }
    }
    
    
    // MARK: - Private functions
    
    private func customizeNavBar() {
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
        let theme = AppState.shared.config?.theme
        let themeColor = theme?.color
        
        var startColor = themeColor?.primaryBrandyStart ?? ThemeColor.default.primaryBrandyStart
        var endColor = themeColor?.primaryBrandyEnd ?? ThemeColor.default.primaryBrandyEnd
        if presenter.shouldUseCredifyTheme() {
            startColor = ThemeColor.default.primaryBrandyStart
            endColor = ThemeColor.default.primaryBrandyEnd
        }
        
        navBar.setGradientBackground(
            colors: [
                UIColor.fromHex(startColor),
                UIColor.fromHex(endColor)
            ],
            startPoint: .centerLeft,
            endPoint: .centerRight
        )
        
        // TODO I will update it later
        let titleFont: UIFont? = nil //AppState.shared.config?.theme.font.primaryPageTitle
        if titleFont != nil {
            navBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: titleFont!
            ]
        } else {
            navBar.titleTextAttributes = [
                .foregroundColor: UIColor.white,
            ]
        }
        
        navBar.tintColor = UIColor.fromHex(themeColor?.primaryIconColor ?? "#FFFFFF")
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
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "ic_close", in: Bundle.serviceX, with: nil),
                style: .plain,
                target: self,
                action: #selector(close)
            )
        } else {
            // Fallback on earlier versions
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "ic_close", in: Bundle.serviceX, compatibleWith: nil),
                style: .plain,
                target: self,
                action: #selector(close)
            )
        }
        
        setBackButtonVisibility(isVisible: false)
    }
    
    @objc private func goBack() {
        presenter.goToPreviousPageOrClose(webView: webView)
    }
    
    @objc private func close() {
        presenter.isLoading(webView: webView) { isLoading in
            if !isLoading && !LoadingView.isShowing {
                self.dismiss(animated: true) {
                    self.presenter.hanldeCompletionHandler()
                }
            }
        }
    }

    private func setBackButtonVisibility(isVisible: Bool) {
        if isVisible {
            let themeColor = AppState.shared.config?.theme.color
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.leftBarButtonItem?.tintColor = UIColor.fromHex(themeColor?.primaryIconColor ?? "#FFFFFF")
            return
        }
        
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.tintColor = .clear
    }
    
    private func setCloseButtonVisibility(isVisible: Bool) {
        if isVisible {
            let themeColor = AppState.shared.config?.theme.color
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = UIColor.fromHex(themeColor?.primaryIconColor ?? "#FFFFFF")
            return
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .clear
    }
}

extension WebViewController: WKUIDelegate {
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

extension WebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as? [String: Any]
        
        // 24517: See 2 loading indicators at the same time
        if presenter.shouldDismissLoading(messageName: message.name) {
            LoadingView.stop()
        }
        
        if presenter.shouldClose(messageName: message.name) {
            dismiss(animated: true) {
                self.presenter.handleMessage(self.webView, name: message.name, body: body)
            }
        } else {
            presenter.handleMessage(webView, name: message.name, body: body)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingView.stop()
    }
}


