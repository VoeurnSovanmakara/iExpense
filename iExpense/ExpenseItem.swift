//
//  ExpenseItem.swift
//  iExpense
//
//  Created by sovanmakara on 26/5/26.
//

import Foundation
import SwiftData

@Model
class ExpenseItem {
    var id:     UUID
    var name:   String
    var type:   String
    var amount: Double
    var date:   Date

    init(name: String, type: String, amount: Double, date: Date) {
        self.id     = UUID()
        self.name   = name
        self.type   = type
        self.amount = amount
        self.date   = date
    }
}
