//
//  physicsApp.swift
//  physics
//
//  Created by Георгий Александров on 15.01.2021.
//

import SwiftUI

@main
struct physicsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
