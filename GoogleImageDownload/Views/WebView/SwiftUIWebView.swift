//
//  SwiftUIWebView.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import SwiftUI
import WebKit
import Combine

struct SwiftUIWebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel
    
    let webView = MyWKWebView()
    
    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIView(context: UIViewRepresentableContext<SwiftUIWebView>) -> WKWebView {
    
       self.webView.navigationDelegate = context.coordinator
       self.webView.uiDelegate = context.coordinator
        
        if let url = URL(string: viewModel.link) {
            self.webView.load(URLRequest(url: url))
            return self.webView
        }
        return self.webView
    }
    
    func goBack(){
        self.webView.goBack()
        print("fired goBack")
    }

    func goForward(){
        self.webView.goForward()
        print("fired goForward")
    }
    
    func reload(){
        self.webView.reload()
        print("fired reload")
    }
    

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<SwiftUIWebView>) {
       self.webView.navigationDelegate = context.coordinator
       self.webView.uiDelegate = context.coordinator
       return
    }
    
    //model can be expanded to have a list of allowed websites and navigation rules.
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
            self.viewModel = viewModel

        }
        
        deinit {
            print("Coordinator: deinit")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView:didFinish: navigation finished \(self.viewModel.link)")
            self.viewModel.didFinishLoading = true
            print(self.viewModel.didFinishLoading)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("error with load!!!33")
            self.viewModel.hasLoadingError = true
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> SwiftUIWebView.Coordinator {
        Coordinator(viewModel)
    }
}
