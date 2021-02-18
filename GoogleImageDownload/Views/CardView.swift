//
//  CardView.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import SwiftUI

struct CardView: View {
    
    var labelImage: String
    var labelImageColor: Color
    
    var labelTitle: String
    var labelTitleColor: Color
    
    var bodyText: String
    
    var body: some View {
        //main VStack
        VStack(alignment: .leading) {
            //Card title label
            HStack {
                Label {
                    Text(labelTitle)
                        .minimumScaleFactor(0.25)
                        .font(.title3)
                        .lineLimit(1)
                        .foregroundColor(labelTitleColor)
                    
                } icon: {
                    Image(systemName: labelImage)
                        .minimumScaleFactor(0.25)
                        .font(.title3)
                        .foregroundColor(labelImageColor)
                }
                Spacer()
            }
            
            //Text HStack
            HStack {
                Text(bodyText)
                    .minimumScaleFactor(0.25)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .padding()
        .background(CardBackgroundView())
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
       
        CardView(labelImage: "lightbulb", labelImageColor: .red, labelTitle: "Tips", labelTitleColor: .gray, bodyText: "this is a test")

    }
}
