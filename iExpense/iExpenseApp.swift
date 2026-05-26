//
//  iExpenseApp.swift
//  iExpense
//
//  Created by sovanmakara on 11/5/26.
//

import SwiftUI
import SwiftData

@main
struct iExpenseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ExpenseItem.self)
    }
}
