//
//  TransactionRow.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    let card: BankCard?

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy HH:mm"
        f.locale = Locale(identifier: "ru_RU")
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            Image(transaction.iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchant).font(.headline)
                HStack(spacing: 6) {
                    Text(Self.formatter.string(from: transaction.date))
                    if let card = card {
                        Text("•").foregroundColor(.secondary)
                        Text(card.displayName).foregroundColor(.secondary)
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.2f", transaction.amount))
                    .font(.headline)
                Text(transaction.currency)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
    }
}
