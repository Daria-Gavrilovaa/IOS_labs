//
//  StatisticsViewModel.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation
import Combine

final class StatisticsViewModel: ObservableObject {

    struct Slice: Identifiable {
        let id = UUID()
        let category: String
        let total: Double
    }

    @Published private(set) var slices: [Slice] = []
    @Published private(set) var total: Double = 0

    private let transactionsVM: TransactionsViewModel
    private var cancellables = Set<AnyCancellable>()

    init(transactionsVM: TransactionsViewModel) {
        self.transactionsVM = transactionsVM

        transactionsVM.$transactions
            .map(Self.group)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] slices in
                guard let self = self else { return }
                self.slices = slices
                self.total = slices.reduce(0) { $0 + $1.total }
            }
            .store(in: &cancellables)
    }

    private static func group(_ items: [Transaction]) -> [Slice] {
        Dictionary(grouping: items, by: { $0.category })
            .map { Slice(category: $0.key,
                         total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }
}
