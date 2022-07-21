//
//  WebViewController.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import UIKit
import WebKit
import SafariServices

class WebViewController: SimpleWebViewController {
    private var presenter: WebPresenterProtocol!
    
    override var shouldShowNavBar: Bool {
        get {
            return false
        }
    }
    
    override var shouldClearCache: Bool {
        get {
            return true
        }
    }
    
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
        let isBackgroundTransparent = presenter.shouldUseTransparentBackground(url: self.url.absoluteString)
        
        observerShowHideKeyboardEvent()
        
        // 23462: Med247 app - Passport's background does not fit with height of Med247 app
        updateBackground(themeColor: themeColor, isTransparentBackground: isBackgroundTransparent)
        
        updateWebViewBackground(themeColor: themeColor, isTransparentBackground: isBackgroundTransparent)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Scroll the WKWebView once the page is changed
        if keyPath == #keyPath(WKWebView.url) {
            webView.scrollView.setContentOffset(CGPoint.zero, animated: true)
            
            let url = webView.url
            let theme = AppState.shared.config?.theme
            let themeColor = theme?.color
            let isBackgroundTransparent = presenter.shouldUseTransparentBackground(url: url?.absoluteString ?? "")
            updateBackground(themeColor: themeColor, isTransparentBackground: isBackgroundTransparent)
            updateWebViewBackground(themeColor: themeColor, isTransparentBackground: isBackgroundTransparent)
        }
    }
    
    override func createWebView() -> WKWebView {
        let userController = createWebViewUserContentController()
        let configuration = createWebViewConfiguration(userController: userController)
        
        let webView = WKWebView(frame: webViewFrame, configuration: configuration)
        
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
        // Disable preview to avoid white page
        webView.allowsLinkPreview = false
        
        return webView
    }
    
    
    // MARK: - Private functions
    
    private func createWebViewConfiguration(userController: WKUserContentController) -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        
        configuration.userContentController = userController
        
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
    
    private func createWebViewUserContentController() -> WKUserContentController {
        let userController = WKUserContentController()
        
        presenter.receiveHandlers.forEach { handler in
            userController.add(self, name: handler.rawValue)
        }
        
        return userController
    }
    
    private func updateWebViewBackground(themeColor: ThemeColor?, isTransparentBackground: Bool) {
        if isTransparentBackground {
            webView.backgroundColor = .clear
            webView.isOpaque = false
            return
        }
        
        let bgColor = themeColor?.secondaryBackground ?? "#FFFFFF"
        webView.backgroundColor = UIColor.fromHex(bgColor)
        webView.isOpaque = true
    }
    
    private func observerShowHideKeyboardEvent() {
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
    }
    
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
    
    private func updateBackground(
            themeColor: ThemeColor?,
            isTransparentBackground: Bool = false
    ) {
        if isTransparentBackground {
            view.setGradient(
                colors: [UIColor.clear, UIColor.clear],
                startPoint: CGPoint(x: 0, y: 0.5),
                endPoint: CGPoint(x: 1, y: 0.5)
            )
            
            maskBackgroud.backgroundColor = UIColor.clear
            return
        }
        
        let bgColor = themeColor?.secondaryBackground ?? "#FFFFFF"
        view.backgroundColor = UIColor.fromHex(bgColor)
        
        var startColor = themeColor?.primaryBrandyStart ?? ThemeColor.default.primaryBrandyStart
        var endColor = themeColor?.primaryBrandyEnd ?? ThemeColor.default.primaryBrandyEnd
        if presenter.shouldUseCredifyTheme() {
            startColor = ThemeColor.default.primaryBrandyStart
            endColor = ThemeColor.default.primaryBrandyEnd
        }
        maskBackgroud.setGradient(
            colors: [
                UIColor.fromHex(startColor),
                UIColor.fromHex(endColor)
            ],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 1, y: 0.5)
        )
    }
}

extension WebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as? [String: Any]
        
        if presenter.shouldClose(messageName: message.name) {
            dismiss(animated: true) {
                self.presenter.handleMessage(self.webView, name: message.name, body: body)
            }
            return
        }
        
        if presenter.isOpenRedirectUrlMessageForOffer(name: message.name) {
            if let urlStr = presenter.extractRedirectUrlForOffer(body: body), let url = URL(string: urlStr) {
                let vc = SimpleWebViewController.instantiate(url: url)
                let navigationController = UIUtils.createUINavigationController(vc: vc)
                present(navigationController, animated: true)
                return
            }
        }
        
        presenter.handleMessage(webView, name: message.name, body: body)
    }
}

extension WebViewController : UIScrollViewDelegate {
    /// Don't allow the webview to scroll
    /// The passport will handle it
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        webView.scrollView.setContentOffset(CGPoint.zero, animated: false)
    }
}
