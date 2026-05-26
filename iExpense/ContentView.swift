//
//  ContentView.swift
//  iExpense
//

import SwiftUI
import SwiftData

// MARK: - Sort & Filter Enums

enum SortOption: String, CaseIterable {
    case name   = "Name"
    case amount = "Amount"
}

enum FilterOption: String, CaseIterable {
    case all      = "All"
    case personal = "Personal"
    case business = "Business"
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [ExpenseItem]

    @State private var sortOption: SortOption   = .name
    @State private var filterOption: FilterOption = .all

    // MARK: - Derived Lists

    private var processedItems: [ExpenseItem] {
        let filtered: [ExpenseItem]
        switch filterOption {
        case .all:      filtered = allItems
        case .personal: filtered = allItems.filter { $0.type == "Personal" }
        case .business: filtered = allItems.filter { $0.type == "Business" }
        }
        switch sortOption {
        case .name:   return filtered.sorted { $0.name   < $1.name }
        case .amount: return filtered.sorted { $0.amount > $1.amount }
        }
    }

    private var personalItems: [ExpenseItem] {
        processedItems.filter { $0.type == "Personal" }
    }

    private var businessItems: [ExpenseItem] {
        processedItems.filter { $0.type == "Business" }
    }

    // MARK: - Delete

    private func removePersonalItems(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(personalItems[index]) }
    }

    private func removeBusinessItems(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(businessItems[index]) }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {

                // Active sort / filter chips
                if sortOption != .name || filterOption != .all {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if sortOption != .name {
                                    Chip(label: "↑ \(sortOption.rawValue)", color: .blue) {
                                        sortOption = .name
                                    }
                                }
                                if filterOption != .all {
                                    Chip(label: filterOption.rawValue,
                                         color: filterOption == .personal ? .green : .blue) {
                                        filterOption = .all
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }

                // MARK: Personal Section
                if filterOption == .all || filterOption == .personal {
                    Section {
                        ForEach(personalItems) { item in
                            ExpenseRow(item: item)
                        }
                        .onDelete(perform: removePersonalItems)
                    } header: {
                        if personalItems.isEmpty{
                            EmptyView()
                        } else {
                            Label("Personal", systemImage: "person.fill")
                        }
                    }
                }

                // MARK: Business Section
                if filterOption == .all || filterOption == .business {
                    Section {
                        ForEach(businessItems) { item in
                            ExpenseRow(item: item)
                        }
                        .onDelete(perform: removeBusinessItems)
                    } header: {
                        if businessItems.isEmpty {
                            EmptyView()
                        } else {
                            Label("Business", systemImage: "briefcase.fill")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("iExpense")
            .navigationBarBackButtonHidden()
            .toolbar {

                // Sort & Filter menu
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        // Sort submenu
                        Menu {
                            Picker("Sort by", selection: $sortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Label(
                                        option.rawValue,
                                        systemImage: option == .name
                                            ? "textformat"
                                            : "dollarsign.circle"
                                    )
                                    .tag(option)
                                }
                            }
                        } label: {
                            Label("Sort by", systemImage: "arrow.up.arrow.down")
                        }

                        // Filter submenu
                        Menu {
                            Picker("Filter", selection: $filterOption) {
                                ForEach(FilterOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }

                // Add button
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddView()
                    } label: {
                        Label("Add Expense", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if allItems.isEmpty {
                    ContentUnavailableView(
                        "No Expenses Yet",
                        systemImage: "creditcard",
                        description: Text("Tap the + button to add your first expense.")
                    )
                }
            }
        }
    }
}

// MARK: - Chip (active-filter badge)

private struct Chip: View {
    let label: String
    let color: Color
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption.weight(.medium))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
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

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Text(item.amount, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
                    .foregroundColor(amountColor(item.amount))
            }
        }
        .padding(.vertical, 6)
    }

    func colorForType(_ type: String) -> Color  { type == "Business" ? .blue : .green }
    func iconForType(_ type: String) -> String   { type == "Business" ? "briefcase.fill" : "person.fill" }
    func amountColor(_ amount: Double) -> Color {
        switch amount {
        case 0..<10:   return .green
        case 10..<100: return .orange
        default:       return .red
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ExpenseItem.self, inMemory: true)
}
