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
    
    private var originalWebViewFrame: CGRect? = nil
    
    static func instantiate(context: PassportContext) -> WebViewController {
        let vc = WebViewController()
        vc.url = context.url
        vc.presenter = WebPresenter(context: context)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theme = AppState.shared.config?.theme
        let themeColor = theme?.color
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        // 23462: Med247 app - Passport's background does not fit with height of Med247 app
        updateBackground(themeColor: themeColor)
        
        customizeNavBar(themeColor: themeColor)
            
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
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        // Have nav bar
        // let navAndStatusBarHeight = (navigationController?.navigationBar.frame.height ?? 0) + statusBarHeight
        // Have not nav bar
        let navAndStatusBarHeight = statusBarHeight
        
        // 21840: UI issue - Long text and cut off button
        let webViewHeight: CGFloat
        var safeAreaInsetsBottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeAreaInsetsBottom = 8.0
            webViewHeight = view.safeAreaLayoutGuide.layoutFrame.height - navAndStatusBarHeight
        } else {
            webViewHeight = view.frame.height - navAndStatusBarHeight
        }
        
        // Background
        let bgColor = themeColor?.secondaryBackground ?? "#FFFFFF"
        let bg = UIView(
            frame: CGRect(
                x: 0,
                y: statusBarHeight,
                width: view.frame.width,
                height: webViewHeight
            )
        )
        bg.backgroundColor = UIColor.fromHex(bgColor)
        view.addSubview(bg)
        
        webView = WKWebView(
            frame: CGRect(
                x: 0,
                y: statusBarHeight,
                width: view.frame.width,
                height: webViewHeight - safeAreaInsetsBottom
            ),
            configuration: configuration
        )
        view.addSubview(webView)
        
        self.originalWebViewFrame = webView.frame
        
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
            webView.scrollView.delegate = self

            webView.allowsBackForwardNavigationGestures = true
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
            webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
            webView.customUserAgent = AppState.shared.config?.userAgent
            // Disable scroll
            webView.scrollView.bounces = false
            webView.scrollView.isScrollEnabled = false
            
            webView.load(URLRequest(url: url))
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
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let frame = self.originalWebViewFrame,
           let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            webView.frame = CGRect(
                x: frame.origin.x,
                y: frame.origin.y,
                width: frame.width,
                height: frame.height - keyboardSize.height
            )
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.originalWebViewFrame == nil {
            return
        }
        
        webView.frame = self.originalWebViewFrame!
    }
    
    private func updateBackground(themeColor: ThemeColor?) {
        var startColor = themeColor?.primaryBrandyStart ?? ThemeColor.default.primaryBrandyStart
        var endColor = themeColor?.primaryBrandyEnd ?? ThemeColor.default.primaryBrandyEnd
        if presenter.shouldUseCredifyTheme() {
            startColor = ThemeColor.default.primaryBrandyStart
            endColor = ThemeColor.default.primaryBrandyEnd
        }
        
        view.setGradient(
            colors: [
                UIColor.fromHex(startColor),
                UIColor.fromHex(endColor)
            ],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 1, y: 0.5)
        )
    }
    
    private func customizeNavBar(themeColor: ThemeColor?) {
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
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
        navBar.isHidden = true
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

extension WebViewController : UIScrollViewDelegate {
    /// Don't allow the webview to scroll
    /// The passport will handle it
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        webView.scrollView.setContentOffset(CGPoint.zero, animated: false)
    }
}
