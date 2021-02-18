//
//  TitleCard.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2021-02-17.
//

import SwiftUI

struct TitleCard: View {
    
    var body: some View {
            VStack {
                //Title HStack -> Two color
                HStack() {
                    Image(systemName: "magnifyingglass").foregroundColor(.titleColor1)
                }.font(.system(size: 60, weight: .semibold, design: .rounded))
                HStack() {
                    Image(systemName: "photo").foregroundColor(.titleColor3)
                }.font(.system(size: 60, weight: .semibold, design: .rounded))
                HStack() {
                    Image(systemName: "square.and.arrow.down.on.square").foregroundColor(.titleColor5)
                }.font(.system(size: 60, weight: .semibold, design: .rounded))
        }
    }
}

struct TitleCard_Previews: PreviewProvider {
    static var previews: some View {
        TitleCard()
            .preferredColorScheme(.dark)
    }
}
