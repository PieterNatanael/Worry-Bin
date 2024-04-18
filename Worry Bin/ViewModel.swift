//
//  ViewModel.swift
//  Worry Bin
//
//  Created by Pieter Yoshua Natanael on 18/04/24.
//

import SwiftUI
import Combine

class WorryViewModel: ObservableObject {
    @Published var worries: [Worry] = []

    private let dataManager = DataManager()

    init() {
        loadWorries()
    }

    func loadWorries() {
        worries = dataManager.loadWorries()
    }

    func saveWorry(_ worry: Worry) {
        dataManager.saveWorry(worry)
        loadWorries()
    }

    func deleteWorry(atOffsets offsets: IndexSet) {
        dataManager.deleteWorry(atOffsets: offsets)
        loadWorries()
    }
}
