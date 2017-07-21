//
//  WebViewController.swift
//  Smashtag
//
//  Created by Olivier van den Biggelaar on 20/07/2017.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            webView.delegate = self
            webView.scalesPageToFit = true
            loadURL()
        }
    }
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    @IBAction func closeWebView(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    var url: URL? {
        didSet {
            title = url?.host
            loadURL()
        }
    }
    
    private func loadURL() {
        if let url = url {
            webView?.loadRequest(URLRequest(url: url))
        }
    }

    // MARK: - Users interaction
    
    @IBAction func navigateToPreviousWebPageOrVC(_ sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.stopAnimating()
        print("Page Load Error")
    }


}
