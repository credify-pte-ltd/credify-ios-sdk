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
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        let navAndStatusBarHeight = (navigationController?.navigationBar.frame.height ?? 0) + statusBarHeight
        
        // 21840: UI issue - Long text and cut off button
        let webViewHeight: CGFloat
        if #available(iOS 11.0, *) {
            webViewHeight = view.safeAreaLayoutGuide.layoutFrame.height - navAndStatusBarHeight - (window?.safeAreaInsets.bottom ?? 0.0)
        } else {
            webViewHeight = view.frame.height - navAndStatusBarHeight
        }
        webView = WKWebView(
            frame: CGRect(
                x: 0,
                y: navAndStatusBarHeight,
                width: view.frame.width,
                height: webViewHeight
            ),
            configuration: configuration
        )
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        webView.uiDelegate = self

        webView.load(URLRequest(url: url))

        webView.allowsBackForwardNavigationGestures = true
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
        webView.customUserAgent = AppState.shared.config?.userAgent
        
        webView.navigationDelegate = self
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
    }
    
    
    // MARK: - Private functions
    
    private func customizeNavBar() {
        guard let navBar = navigationController?.navigationBar else {
            return
        }
        
        let theme = AppState.shared.config?.theme
        let themeColor = theme?.color
        let startColor = themeColor?.primaryBrandyStart ?? ThemeColor.default.primaryBrandyStart
        let endColor = themeColor?.primaryBrandyEnd ?? ThemeColor.default.primaryBrandyEnd
        navBar.setGradientBackground(colors: [UIColor.fromHex(startColor), UIColor.fromHex(endColor)], startPoint: .topLeft, endPoint: .bottomRight)
        
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
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc private func close() {
        dismiss(animated: true) {
            self.presenter.hanldeCompletionHandler()
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

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // BNPL and Offer flow will post a message(market proxy also needs this message)
        // to native app once the web app is loaded
        // So the app only needs to post a message
        // to web app for the login case(My Page and Service Instance)
        presenter.doPostMessageForLoggingIn(webView: webView)
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

