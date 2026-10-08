//
//  TransactionsView.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import SwiftUI
import UniformTypeIdentifiers

struct TransactionsView: View {

    @ObservedObject var viewModel: TransactionsViewModel
    let cards: [BankCard]
    let preferredAccountId: UUID?

    @State private var showImporter = false
    @State private var showAccountPicker = false
    @State private var pendingImportURL: URL?

    var body: some View {
        VStack(spacing: 12) {

            HStack {
                TextField("Search...", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)

                Button {
                    showImporter = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                }
                .disabled(viewModel.isImporting)
            }
            .padding(.horizontal)

            if viewModel.isImporting {
                ProgressView("Импорт...")
            }

            if let warning = viewModel.importWarning {
                Text(warning)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal)
            }

            LazyVStack(spacing: 4) {
                ForEach(viewModel.filteredTransactions) { tx in
                    NavigationLink {
                        TransactionDetailView(
                            transaction: tx,
                            card: cards.first { $0.id == tx.accountId }
                        )
                    } label: {
                        TransactionRow(
                            transaction: tx,
                            card: cards.first { $0.id == tx.accountId }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                if let preferred = preferredAccountId {
                    viewModel.importTrigger.send(
                        TransactionsViewModel.ImportPayload(
                            url: url, accountId: preferred
                        )
                    )
                } else {
                    pendingImportURL = url
                    showAccountPicker = true
                }
            case .failure(let error):
                print("fileImporter error: \(error)")
            }
        }
        .sheet(isPresented: $showAccountPicker) {
            ImportAccountPickerView(cards: cards) { selected in
                if let url = pendingImportURL, let card = selected {
                    viewModel.importTrigger.send(
                        TransactionsViewModel.ImportPayload(
                            url: url, accountId: card.id
                        )
                    )
                }
                pendingImportURL = nil
                showAccountPicker = false
            }
        }
        .alert(isPresented: Binding(
            get: { viewModel.importError != nil },
            set: { _ in viewModel.reload() }
        )) {
            Alert(
                title: Text("Ошибка импорта"),
                message: Text(viewModel.importError ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
