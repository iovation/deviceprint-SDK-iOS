//
//  SampleWKWebViewViewController.swift
//  iovSampleSwift
//
//  Copyright © 2017 iovation Inc. All rights reserved.
//

import UIKit
import WebKit
import FraudForce

class SampleWKWebViewViewController: UIViewController {
    @IBOutlet weak var webkitContainer: UIView!
    weak var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        createWebView()
        loadWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SampleWKWebViewViewController {
    func createWebView() {
        // Set up an on-load script, via a WKUserScript that is injected "AtDocumentEnd".
        // The script both populates the textarea element (whose id=bb) with a blackbox string, and it
        // defines a Blackbox object literal whose injectInto property is a function that triggers the
        // WKScriptMessageHandler protocol method defined in this class.
        let blackbox = FraudForce.blackbox()
        let urlString = UserDefaults.standard.string(forKey: "blackboxURL") ?? ""
        let jsCode = "document.getElementById('bb').value = '\(blackbox)'\nvar Blackbox = { injectInto: function (id) { window.webkit.messageHandlers.bb.postMessage(id) } }\ndocument.getElementById('url').value = '\(urlString)'\n"
        let userScript = WKUserScript(source: jsCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        // Set up bb notification.
        userContentController.add(self, name: "bb")
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = userContentController
        
        // Create the WebKit-based WebView, and install it into the view hierarchy.
        let webKitView = WKWebView(frame: webkitContainer.bounds, configuration: webViewConfig)
        webkitContainer.addSubview(webKitView)
        webKitView.translatesAutoresizingMaskIntoConstraints = true
        webKitView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        webView = webKitView
    }
    
    @IBAction func loadWebView() {
        // Load up the webView with content.
        if let pageTitle = webView?.title, !pageTitle.isEmpty {
            // The webView is already displaying the html web page from the app bundle. Inject a new
            // blackbox in response to the reload request.
            let blackbox = FraudForce.blackbox()
            let jsCode = "document.getElementById('bb').value = '\(blackbox)'"
            webView?.evaluateJavaScript(jsCode, completionHandler: nil)
        } else {
            if let bundleHtmlUrl = Bundle.main.url(forResource: "webkit", withExtension: "html") {
                do {
                    let htmlString = try String(contentsOf: bundleHtmlUrl, encoding: .utf8)
                    _ = webView?.loadHTMLString(htmlString, baseURL: nil)
                } catch {
                    // Catch-all to prevent the error from propagating.
                }
            }
        }
    }
}

extension SampleWKWebViewViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Consider checking properties of message.webView.URL, such as the host property, to ensure 
        // that it's a request from a known source.
        guard message.name == "bb" else {
            return
        }
        
        // Inject the blackbox.
        let blackbox = FraudForce.blackbox()
        message.webView?.evaluateJavaScript("document.getElementById('\(message.body)').value = '\(blackbox)'", completionHandler: nil)
    }
}
