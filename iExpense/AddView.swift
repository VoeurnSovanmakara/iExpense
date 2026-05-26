//
//  AddView.swift
//  iExpense
//
//  Created by sovanmakara on 12/5/26.
//

import SwiftUI
import SwiftData

struct AddView: View {
    @State private var name = ""
    @State private var amount = 0.0
    @State private var type = "Personal"
    @State private var selectedDate = Date()
    
    let types = ["Personal", "Business"]
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    HStack {
                        Image(systemName: "textformat")
                            .foregroundColor(.blue)
                        TextField("Expense name", text: $name)
                            .disableAutocorrection(true)
                    }
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.orange)
                        Picker("Type", selection: $type) {
                            ForEach(types, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
                Section("Amount") {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        TextField(
                            "Amount",
                            value: $amount,
                            format: .currency(code: "USD")
                        )
                        .keyboardType(.decimalPad)
                    }
                }
                
                Section("Date") {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.brown)
                        
                        DatePicker(
                            "Select a Date",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let item = ExpenseItem(
                            name: name,
                            type: type,
                            amount: amount,
                            date: selectedDate
                        )
                        
                        modelContext.insert(item)
                        dismiss()
                        
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .disabled(name.isEmpty || amount <= 0)
                }
            }
        }
    }
}

#Preview {
    AddView()
        .modelContainer(for: ExpenseItem.self, inMemory: true)
}
