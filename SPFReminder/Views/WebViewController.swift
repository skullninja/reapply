//
//  WebViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 6/18/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var urlString: String!
    @IBOutlet weak var btnClose: UIButton!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        // 1
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
        
        // 2
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = false
        
        
        
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 65, y: 30, width: 47, height: 47))
        button.layer.cornerRadius = button.bounds.width / 2.0
        button.setImage(UIImage(named: "cross-white"), for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(Float(webView.estimatedProgress))
        }
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
}
