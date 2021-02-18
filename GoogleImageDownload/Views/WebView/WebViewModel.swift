//
//  WebViewModel.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2020-04-17.
//  Copyright © 2021 Stanislav Jidkov. All rights reserved.
//

import Foundation

class WebViewModel: ObservableObject {
    @Published var link: String
    @Published var type: String
    @Published var name: String
    @Published var didFinishLoading: Bool = false
    @Published var hasLoadingError: Bool = false    
    
    init (link: String, type: String, name: String) {
        self.link = link
        self.type = type
        self.name = name
    }
}
