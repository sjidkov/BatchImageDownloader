//
//  InfoView.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import SwiftUI

import SwiftUI

struct InfoView: View {
    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical) {
                VStack() {
                CardView(labelImage: "questionmark.circle",
                         labelImageColor: .titleColor1,
                         labelTitle: "What is  Google Images Downloader?",
                         labelTitleColor: .titleColor2,
                         bodyText: "Google Images Downloader is a fast and easy way to search and download images from google image search.")
                    .frame(width: geo.size.width * 0.9)
                    
                CardView(labelImage: "magnifyingglass",
                         labelImageColor: .titleColor3,
                         labelTitle: "How do I search?",
                         labelTitleColor: .titleColor4,
                         bodyText: "Type some words into the search field and hit return on the keyboard.  Results will appear shortly after.")
                    .frame(width: geo.size.width * 0.9)
                    
                CardView(labelImage: "square.and.arrow.down.on.square",
                         labelImageColor: .titleColor5,
                         labelTitle: "How can I save images?",
                         labelTitleColor: .titleColor6,
                         bodyText: "You can save and share images either one at a time by clicking the share button on the results view.\nOr you can batch save/share all image results by tapping the extras menu (ellipsis) button and selecting batch download.")
                    .frame(width: geo.size.width * 0.9)
                    
                }.frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}

