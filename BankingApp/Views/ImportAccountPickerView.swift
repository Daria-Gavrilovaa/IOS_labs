//
//  ImportAccountPickerView.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import SwiftUI

struct ImportAccountPickerView: View {
    let cards: [BankCard]
    let onSelect: (BankCard?) -> Void

    var body: some View {
        NavigationView {
            List {
                Section("Выберите счёт для импорта") {
                    ForEach(cards) { card in
                        Button {
                            onSelect(card)
                        } label: {
                            HStack {
                                Image(card.iconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 25)
                                VStack(alignment: .leading) {
                                    Text(card.currency).font(.headline)
                                    Text(card.displayName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Счёт")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { onSelect(nil) }
                }
            }
        }
    }
}
