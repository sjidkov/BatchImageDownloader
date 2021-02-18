//
//  BrowserView.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

/*
 Shows website content and manages site navigation
 */

import SwiftUI

struct BrowserView: View {
    
    @ObservedObject var model:  WebViewModel
    @State var pageView: SwiftUIWebView?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
               VStack() {
                self.pageView
                
                HStack() {
                    
                    Button(action: {
                            print("BrowserView: back button tapped")
                        self.pageView?.goBack()
                                }) {
                        Image(systemName: "arrow.left").padding()
                    }
                    Spacer()
                    Button(action: {
                            print("BrowserView: forward button tapped")
                        self.pageView?.goForward()
                                }) {
                    Image(systemName: "arrow.right")
                    }
                    Spacer()
                    Button(action: {
                            print("BrowserView: back button tapped")
                        self.pageView?.reload()
                                }) {
                        Image(systemName: "arrow.clockwise").padding()
                    }
                    
                }.frame(width: geometry.size.width, height: (geometry.size.height * 0.05) > 50 ? geometry.size.height * 0.05 : 50)}.opacity(self.model.hasLoadingError ? 0 : 1)
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            if self.model.hasLoadingError {
                Text("Error")
                }
            }
            .navigationBarTitle("\(self.model.name)", displayMode: .inline)
            .onAppear() {
                    self.setPageView()
                    print("view appeared!!!")
            }
        }
    
    
    func setPageView() {
        self.pageView = SwiftUIWebView(viewModel: model)
    }
}
