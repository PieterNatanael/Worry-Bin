//
//  DataManager.swift
//  Worry Bin
//
//  Created by Pieter Yoshua Natanael on 18/04/24.
//

import SwiftUI
import Combine

class DataManager {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func loadWorries() -> [Worry] {
        guard let data = defaults.data(forKey: "SavedWorries") else { return [] }
        guard let loadedWorries = try? decoder.decode([Worry].self, from: data) else { return [] }
        return loadedWorries
    }

    func saveWorry(_ worry: Worry) {
        var savedWorries = loadWorries()
        savedWorries.append(worry)
        if let encoded = try? encoder.encode(savedWorries) {
            defaults.set(encoded, forKey: "SavedWorries")
        }
    }

    func deleteWorry(atOffsets offsets: IndexSet) {
        var savedWorries = loadWorries()
        savedWorries.remove(atOffsets: offsets)
        if let encoded = try? encoder.encode(savedWorries) {
            defaults.set(encoded, forKey: "SavedWorries")
        }
    }
}
