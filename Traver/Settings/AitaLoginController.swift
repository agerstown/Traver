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
        
        if let url = URL(string: "https://iappintheair.appspot.com/oauth/authorize?client_id=02b3caf1-3d41-4431-a565-71653fc973b8&response_type=code&redirect_uri=http://traver-dev.us-east-1.elasticbeanstalk.com/users/aita&scope=user_flights") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonCancelTapped(_ sender: Any) {
        dismiss(animated: true) {
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
}
