//
//  MyWebView.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import Foundation
import WebKit

class MyWKWebView: WKWebView {
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        let preferences = WKPreferences()
    
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        super.init(frame: frame, configuration: configuration)
        
        self.allowsBackForwardNavigationGestures = true
        self.allowsLinkPreview = false
        if #available(iOS 9.0, *) {
            self.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_2_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13D15 Safari/601.1"
        }
        self.autoresizesSubviews = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
