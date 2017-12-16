//
//  AitaLoginController.swift
//  Traver
//
//  Created by Natalia Nikitina on 6/19/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class AitaLoginController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var buttonCancel: UIBarButtonItem!
    
    let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSpinning()
        
        UIApplication.shared.statusBarStyle = .default
        
        webView.delegate = self
        
        if let url = URL(string: AitaHelper.shared.authorisationLink) {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonCancelTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    // MARK: - Spinner
    func startSpinning() {
        activityIndicator.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        webView.isHidden = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    func stopSpinning() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        webView.isHidden = false
    }
}

// MARK: - UIWebViewDelegate
extension AitaLoginController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        stopSpinning()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            if url.relativeString.hasPrefix(AitaHelper.shared.redirectURL) {
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    if let codeItem = components.queryItems?.first {
                        if codeItem.name == "code" {
                            if let code = codeItem.value {
                                AitaHelper.shared.importCountries(code: code) {
                                    self.dismiss(animated: true) {
                                        UIApplication.shared.statusBarStyle = .lightContent
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return true
    }
}
