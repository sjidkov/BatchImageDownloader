//
//  ImageCard.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import SwiftUI

//backgroud for ImageCard
struct CardBackgroundView: View {
    var body: some View {
        Rectangle().foregroundColor(Color(UIColor.tertiarySystemBackground)).cornerRadius(14).shadow(color: .myShadowColor, radius: 1, x: 0, y: 1)
    }
}

//for rounding specific corners on views
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ImageCard: View {
    
    let shareButtonAction: () -> Void
    let deleteButtonAction: () -> Void
    let item: SearchResult
    
    
    //to trigger navLinks of content view
    @Binding var showingFullImage: Bool
    @Binding var showingWebLink: Bool
    @Binding var selectedItem: SearchResult?
    
    var body: some View {
        VStack() {
            image
            buttons
        }.background(CardBackgroundView())
    }
    
    var image: some View {
        Image(uiImage: UIImage(data: item.imageData ?? Data()) ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(14, corners: [.topLeft, .topRight])
            .ignoresSafeArea(.all)
    }
    
    //control HStack
    var buttons: some View {
        HStack() {
            expandImageButton.padding()
            Spacer()
            viewArticleButton
            Spacer()
            shareImageButton
            Spacer()
            deleteImageButton.padding()
        }
    }
    
    //buttons
    //show fullScreen image
    var expandImageButton: some View   {
        Button(action: {
            withAnimation {
                self.selectedItem = item
                self.showingFullImage.toggle() }
        }) {
            Image(systemName: "arrow.up.left.and.arrow.down.right").font(.title3).foregroundColor(.titleColor1)
        }
    }
    
    //show image article webview
    var viewArticleButton: some View   {
        Button(action: {
            withAnimation {
                self.selectedItem = item
                self.showingWebLink.toggle() }
        }) {
            Image(systemName: "globe").font(.title3).foregroundColor(.titleColor2)
        }
    }
    
    //show download/share image action sheet button
    var shareImageButton: some View   {
        Button(action: {
            withAnimation {  shareButtonAction() }
        }) {
            Image(systemName: "square.and.arrow.up").font(.title3).foregroundColor(.titleColor4)
        }
    }
    
    //deletes current image
    var deleteImageButton: some View   {
        Button(action: {
            withAnimation {  deleteButtonAction() }
        }) {
            Image(systemName: "trash").font(.title3).foregroundColor(.titleColor6)
        }
    }
}

struct ImageCard_Previews: PreviewProvider {
    static var previews: some View {
        ImageCard(shareButtonAction: {
            print("test")
        }, deleteButtonAction: {
            print("test")
        }, item: SearchResult(), showingFullImage: .constant(false), showingWebLink: .constant(false), selectedItem: .constant(SearchResult()))
    }
}
