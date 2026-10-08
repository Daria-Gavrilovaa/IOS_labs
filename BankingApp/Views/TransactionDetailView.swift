//
//  TransactionDetailView.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    let card: BankCard?

    private static let fullFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMMM yyyy, HH:mm:ss"
        f.locale = Locale(identifier: "ru_RU")
        return f
    }()

    var body: some View {
        List {
            Section("Операция") {
                row("Точка", transaction.merchant)
                row("Категория", transaction.category)
                row("MCC-код", transaction.mccCode ?? "—")
            }
            Section("Сумма") {
                row("Сумма", String(format: "%.2f %@",
                                    transaction.amount, transaction.currency))
            }
            Section("Дата и счёт") {
                row("Дата и время",
                    Self.fullFormatter.string(from: transaction.date))
                row("Счёт",
                    card.map { "\($0.currency) \($0.displayName)" } ?? "—")
            }
        }
        .navigationTitle("Детали")
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
    }
}
