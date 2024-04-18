//
//  AppDelegate.swift
//  Worry Bin
//
//  Created by Pieter Yoshua Natanael on 18/04/24.
//

import SwiftUI
import CoreData


class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "YourDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data stack: \(error.localizedDescription)")
            }
        }
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // Other AppDelegate methods...
}
