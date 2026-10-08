//
//  TransactionsViewModel.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation
import Combine

final class TransactionsViewModel: ObservableObject {

    // MARK: - Output
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var importError: String?
    @Published private(set) var importWarning: String?
    @Published private(set) var isImporting: Bool = false

    // MARK: - Input
    @Published var searchText: String = ""

    struct ImportPayload {
        let url: URL
        let accountId: UUID
    }

    let importTrigger = PassthroughSubject<ImportPayload, Never>()

    // MARK: - Dependencies
    private let importService: TransactionImportProtocol
    private let transactionRepo: TransactionRepositoryProtocol
    private let mccDirectory: MCCDirectoryProtocol

    private var cancellables = Set<AnyCancellable>()

    init(
        importService: TransactionImportProtocol,
        transactionRepo: TransactionRepositoryProtocol,
        mccDirectory: MCCDirectoryProtocol
    ) {
        self.importService = importService
        self.transactionRepo = transactionRepo
        self.mccDirectory = mccDirectory

        bindSearch()
        bindImport()
        loadInitial()
    }

    // MARK: - Derived
    var filteredTransactions: [Transaction] {
        guard !searchText.isEmpty else { return transactions }
        let q = searchText.lowercased()
        return transactions.filter {
            $0.merchant.lowercased().contains(q)
                || $0.category.lowercased().contains(q)
                || ($0.mccCode?.contains(q) ?? false)
        }
    }

    // MARK: - Pipelines
    private func loadInitial() {
        transactionRepo.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.transactions = items
            }
            .store(in: &cancellables)
    }

    private func bindSearch() {
        $searchText
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func bindImport() {

        importTrigger
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isImporting = true
                self?.importError = nil
                self?.importWarning = nil
            })
            .flatMap { [weak self] payload -> AnyPublisher<(ImportResult, UUID), Never> in
                guard let self = self else {
                    return Empty<(ImportResult, UUID), Never>().eraseToAnyPublisher()
                }

                return self.importService
                    .importFile(at: payload.url)
                    .map { result in (result, payload.accountId) }
                    .handleEvents(receiveCompletion: { [weak self] completion in
                        if case .failure(let err) = completion {
                            DispatchQueue.main.async {
                                self?.importError = err.localizedDescription
                                self?.isImporting = false
                            }
                        }
                    })
                    .catch { _ in
                        Empty<(ImportResult, UUID), Never>().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] pair in
                guard let self = self else { return }
                let (result, accountId) = pair
                if !result.rejected.isEmpty {
                    self.importWarning = "Пропущено записей: \(result.rejected.count)"
                }
                self.saveImported(result, accountId: accountId)
            }
            .store(in: &cancellables)
    }

    private func saveImported(_ result: ImportResult, accountId: UUID) {
        transactionRepo
            .save(result.transactions,
                  accountId: accountId,
                  mccDirectory: mccDirectory)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .failure(let err) = completion {
                    DispatchQueue.main.async {
                        self?.importError = err.localizedDescription
                        self?.isImporting = false
                    }
                }
            })
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.isImporting = false
                    self.loadInitial()
                }
            )
            .store(in: &cancellables)
    }

    func reload() { loadInitial() }
}
