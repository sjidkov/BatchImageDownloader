//
//  FullImageView.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import SwiftUI

struct FullImageView: View {
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var viewState = CGSize.zero
    
    let minScale: CGFloat = 0.2
    let maxScale: CGFloat = 2.5
    
    @State var image: UIImage
    
    let shareButtonAction: () -> Void
    
    var body: some View {
        
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .animation(.spring())
            .offset(x: viewState.width, y: viewState.height)
            .gesture(DragGesture()
                        .onChanged { val in
                            if scale != 1.0 {
                                self.viewState = val.translation
                                
                            } else {
                                self.viewState = CGSize.zero
                            }
                        }
            )
            .gesture(MagnificationGesture()
                        .onChanged { val in
                            let delta = val / self.lastScale
                            self.lastScale = val
                            // if statement to minimize jitter
                            if delta > 0.90 {
                                let newScale = self.scale * delta
                                self.scale = newScale
                            }
                        }
                        .onEnded { _ in
                            self.lastScale = 1.0
                        }
            )
            .scaleEffect(scale)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack(spacing: 20) {
                    centerImageButton
                    zoomInButton
                    zoomOutButton
                    shareImageButton
                }
            }
        }
    }
    
    //buttons
    var centerImageButton: some View   {
        Button(action: {
            withAnimation {
                self.scale = 1.0
                self.lastScale = 1.0
                self.viewState = CGSize.zero
            }
        }) {
            Image(systemName: "viewfinder.circle").font(.title3).foregroundColor(.titleColor1)
        }
    }
    
    var zoomInButton: some View   {
        Button(action: {
            withAnimation {
                if self.scale < self.maxScale {
                    self.scale +=  CGFloat(0.1)
                } else {
                    self.scale = self.maxScale
                }
            }
        }) {
            Image(systemName: "arrow.up.left.and.arrow.down.right.circle").font(.title3).foregroundColor(.titleColor2)
        }
    }
    
    var zoomOutButton: some View   {
        Button(action: {
            withAnimation {
                if self.scale > self.minScale {
                    self.scale -=  CGFloat(0.1)
                }else {
                    self.scale = self.minScale
                }
            }
        }) {
            Image(systemName: "arrow.down.forward.and.arrow.up.backward.circle").font(.title3).foregroundColor(.titleColor4)
        }
    }
    
    var shareImageButton: some View   {
        Button(action: {
            withAnimation {  shareButtonAction() }
        }) {
            Image(systemName: "square.and.arrow.up").font(.title3).foregroundColor(.titleColor6)
        }
    }
}

struct FullImageView_Previews: PreviewProvider {
    static var previews: some View {
        FullImageView(image: UIImage(), shareButtonAction: {
            print("test")
        })
    }
}
