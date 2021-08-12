//
//  RepoCodeViewController.swift
//  Repo List
//
//  Created by Rajiv Puli on 11/08/21.
//

import UIKit
import WebKit

class RepoCodeViewController: UIViewController {

    var activity: UIActivityIndicatorView!
    var webView: WKWebView!
    
    var repoCodeViewModel = RepoCodeViewModel()
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = repoCodeViewModel.repoName
        webView.navigationDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let url = URL(string: repoCodeViewModel.repoURL) {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
        activity = UIActivityIndicatorView()
        activity.color = .gray
        activity.frame = webView.frame
        activity.center = webView.center
        self.webView.addSubview(self.activity)
        self.activity.startAnimating()
        self.activity.hidesWhenStopped = true
    }

}

extension RepoCodeViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activity.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activity.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activity.stopAnimating()
    }
    
}
