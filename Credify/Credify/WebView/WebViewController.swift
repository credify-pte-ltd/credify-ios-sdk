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
    private var maskBackgroud: UIView!
    private var webView: WKWebView!
    
    private var url: URL!
    private var presenter: WebPresenterProtocol!
    
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
    
    static func instantiate(context: PassportContext) -> WebViewController {
        let vc = WebViewController()
        vc.url = context.url
        vc.presenter = WebPresenter(context: context)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        let theme = AppState.shared.config?.theme
        let themeColor = theme?.color
        let isBackgroundTransparent = presenter.shouldUseTransparentBackground(url: self.url.absoluteString)
        
        observerShowHideKeyboardEvent()
        
        // 23462: Med247 app - Passport's background does not fit with height of Med247 app
        updateBackground(themeColor: themeColor, isTransparentBackground: isBackgroundTransparent)
        
        customizeNavBar(themeColor: themeColor)
            
        setupWebView(themeColor: themeColor)
        
        updateWebViewBackground(themeColor: themeColor, isTransparentBackground: isBackgroundTransparent)
        
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
            let theme = AppState.shared.config?.theme
            let themeColor = theme?.color
            let isBackgroundTransparent = presenter.shouldUseTransparentBackground(url: url?.absoluteString ?? "")
            updateBackground(themeColor: themeColor, isTransparentBackground: isBackgroundTransparent)
            updateWebViewBackground(themeColor: themeColor, isTransparentBackground: isBackgroundTransparent)
        }
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
    
    private func setupWebView(themeColor: ThemeColor?) {
        let userController = createWebViewUserContentController()
        let configuration = createWebViewConfiguration(userController: userController)
        
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
            // Disable preview to avoid white page
            webView.allowsLinkPreview = false
            
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
        // Mask background
        if maskBackgroud == nil {
            maskBackgroud = addMaskBackground()
        }
        
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
    
    private func addMaskBackground() -> UIView {
        maskBackgroud = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width,
                height: 100
            )
        )
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
        
        return maskBackgroud
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
