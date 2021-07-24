//
//  DilExTrackerApp.swift
//  Shared
//
//  Created by Daniel Marriner on 25/06/2021.
//

import SwiftUI

@main
struct DilExTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            #if os(iOS)
            DataView()
//            #else
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//            #endif
        }
    }
}
