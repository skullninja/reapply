//
//  WebViewController.swift
//  SPFReminder
//
//  Created by Amber Reyngoudt on 6/18/19.
//  Copyright © 2019 Skull Ninja Inc. All rights reserved.
//

import WebKit
import Pulsator
import Alamofire

class WebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var urlString: String!
    var blogPost = true
    private var isPreloading = false
    
    let pulsatorDarkOrange = Pulsator()
    let pulsatorLightOrange = Pulsator()
    let pulsatorYellow = Pulsator()

    var pulseView: UIView!
    var coverView: UIView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        
        pulseView = UIView(frame: CGRect.init(x: 0, y: 0, width: 120, height: 120))
        coverView = UIView(frame: webView.bounds)
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if blogPost {
            
            coverView.frame = UIScreen.main.bounds
            view.addSubview(coverView)
            coverView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            coverView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            coverView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            coverView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            coverView.backgroundColor = UIColor.colorFromHex(0xF9F5F0)
            
            let radius = pulseView.frame.size.width / 2.0
            pulseView.frame = CGRect.init(x: UIScreen.main.bounds.midX - radius,
                                          y: UIScreen.main.bounds.midY - radius,
                                          width: pulseView.frame.size.width,
                                          height: pulseView.frame.size.height)
            view.addSubview(pulseView)
            pulseView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
            pulseView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
            
            //Inner layer
            pulseView.layer.insertSublayer(pulsatorDarkOrange, at: 0)
            pulsatorDarkOrange.numPulse = 2
            pulsatorDarkOrange.radius = 95.0
            pulsatorDarkOrange.backgroundColor = UIColor(red: 232/255.0, green: 149/255.0, blue: 76/255.0, alpha: 1).cgColor
            pulsatorDarkOrange.animationDuration = 4
            pulsatorDarkOrange.position = CGPoint(x:pulseView.bounds.midX, y:pulseView.bounds.midY)
            
            //Middle layer
            pulseView.layer.insertSublayer(pulsatorLightOrange, at: 0)
            pulsatorLightOrange.numPulse = 2
            pulsatorLightOrange.radius = 105.0
            pulsatorLightOrange.backgroundColor = UIColor(red: 240/255.0, green: 176/255.0, blue: 95/255.0, alpha: 1).cgColor
            pulsatorLightOrange.animationDuration = 4
            pulsatorLightOrange.position = CGPoint(x:pulseView.bounds.midX, y:pulseView.bounds.midY)
            
            //Outer Layer
            pulseView.layer.insertSublayer(pulsatorYellow, at: 0)
            pulsatorYellow.numPulse = 2
            pulsatorYellow.radius = 115.0
            pulsatorYellow.backgroundColor = UIColor(red: 244/255.0, green: 212/255.0, blue: 141/255.0, alpha: 1).cgColor
            pulsatorYellow.animationDuration = 4
            pulsatorYellow.position = CGPoint(x:pulseView.bounds.midX, y:pulseView.bounds.midY)
        
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self.pulsatorLightOrange.start()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(0)) {
                self.pulsatorYellow.start()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                self.pulsatorDarkOrange.start()
            }
        }
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        // 1
        let url = URL(string: urlString)!
        if blogPost {
            isPreloading = true
        }
        var urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        
        urlRequest.httpShouldUsePipelining = true
        
        webView.allowsBackForwardNavigationGestures =  true
        
        webView.load(urlRequest)
        
        // 2
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [refresh]
        navigationController?.isToolbarHidden = false
        
    }
    
    override func viewWillLayoutSubviews() {
          let width = self.view.frame.width
          let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
          self.view.addSubview(navigationBar);
          let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(closeTapped))
          navigationItem.leftBarButtonItem = doneBtn
          navigationBar.setItems([navigationItem], animated: false)
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
        if isPreloading {
            pulsatorLightOrange.stop()
            pulsatorDarkOrange.stop()
            pulsatorYellow.stop()
            webView.evaluateJavaScript("(document.querySelector('iframe') || {}).src;") { (result, _) in
                if let result = result as? String, let blogPage = URL(string: result) {
                    var urlRequest = URLRequest(url: blogPage, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 360)
                    urlRequest.httpShouldUsePipelining = true
                    webView.load(urlRequest)
                } else {
                    webView.isHidden = false
                    self.title = webView.title
                }
                self.isPreloading = false
                UIView.animate(withDuration: 2.0, animations: {
                    self.coverView.alpha = 0
                })
            }
        } else {
            title = webView.title
            if blogPost {
                webView.evaluateJavaScript("document.querySelector('#content-wrapper div').remove();", completionHandler: nil)
            }
        }
    }
}
