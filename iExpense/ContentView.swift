//
//  ContentView.swift
//  iExpense
//
//  Created by sovanmakara on 11/5/26.
//

import SwiftUI
import Observation

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    
    // MARK: - Filtered Lists
    
    var personalItems: [ExpenseItem] {
        expenses.item.filter { $0.type == "Personal" }
    }
    
    var businessItems: [ExpenseItem] {
        expenses.item.filter { $0.type == "Business" }
    }
    
    // MARK: - Delete
    
    func removePersonalItems(at offsets: IndexSet) {
        let itemsToRemove = offsets.map { personalItems[$0] }
        
        expenses.item.removeAll { item in
            itemsToRemove.contains(where: { $0.id == item.id })
        }
    }
    
    func removeBusinessItems(at offsets: IndexSet) {
        let itemsToRemove = offsets.map { businessItems[$0] }
        
        expenses.item.removeAll { item in
            itemsToRemove.contains(where: { $0.id == item.id })
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                
                // MARK: - Personal Section
                
                Section {
                    ForEach(personalItems) { item in
                        ExpenseRow(item: item)
                    }
                    .onDelete(perform: removePersonalItems)
                    
                } header: {
                    Label("Personal", systemImage: "person.fill")
                }
                
                
                // MARK: - Business Section
                
                Section {
                    ForEach(businessItems) { item in
                        ExpenseRow(item: item)
                    }
                    .onDelete(perform: removeBusinessItems)
                    
                } header: {
                    Label("Business", systemImage: "briefcase.fill")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("iExpense")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddView(expenses: expenses)
                    } label: {
                        Label("Add Expense", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if expenses.item.isEmpty {
                    ContentUnavailableView(
                        "No Expenses Yet",
                        systemImage: "creditcard",
                        description: Text(
                            "Tap the + button to add your first expense."
                        )
                    )
                }
            }
        }
//        .sheet(isPresented: $showingAddExpense) {
//            AddView(expenses: expenses)
//        }
    }
}


// MARK: - Expense Row

struct ExpenseRow: View {
    let item: ExpenseItem
    
    var body: some View {
        HStack(spacing: 16) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorForType(item.type).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconForType(item.type))
                    .foregroundColor(colorForType(item.type))
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.type)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
               
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4){
                Text(item.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                Text(
                    item.amount,
                    format: .currency(code: "USD")
                )
                .fontWeight(.semibold)
                .foregroundColor(amountColor(item.amount))
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Helpers
    
    func colorForType(_ type: String) -> Color {
        type == "Business" ? .blue : .green
    }
    
    func iconForType(_ type: String) -> String {
        type == "Business"
        ? "briefcase.fill"
        : "person.fill"
    }
    
    func amountColor(_ amount: Double) -> Color {
        switch amount {
        case 0..<10:
            return .green
        case 10..<100:
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    ContentView()
}

struct ExpenseItem: Identifiable, Codable{
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
    let date: Date
}

@Observable
class Expenses{
    var item = [ExpenseItem](){
        didSet{
            if let encoder = try? JSONEncoder().encode(item){
                UserDefaults.standard.set(encoder, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItem = UserDefaults.standard.data(forKey: "Items"){
            if let decodedItem = try? JSONDecoder().decode([ExpenseItem].self, from: savedItem){
                item = decodedItem
                return
            }
        }
        
        item = []
    }
}
