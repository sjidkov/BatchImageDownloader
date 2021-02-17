//
//  GoogleImageDownloadApp.swift
//  GoogleImageDownload
//
//  Created by Stanislav Jidkov on 2021-02-16.
//

import SwiftUI

@main
struct GoogleImageDownloadApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
