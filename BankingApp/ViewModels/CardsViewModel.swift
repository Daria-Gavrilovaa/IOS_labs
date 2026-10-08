//
//  CardsViewModel.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation
import Combine

final class CardsViewModel: ObservableObject {

    @Published private(set) var cards: [BankCard] = []
    @Published private(set) var selectedCardId: UUID?

    private let cardRepo: CardRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(cardRepo: CardRepositoryProtocol) {
        self.cardRepo = cardRepo

        cardRepo.seedIfNeeded()
            .catch { _ in Just(()).eraseToAnyPublisher() }
            .flatMap { [weak self] _ -> AnyPublisher<[BankCard], Never> in
                guard let self = self else {
                    return Empty<[BankCard], Never>().eraseToAnyPublisher()
                }
                return self.cardRepo.fetchAll()              
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.cards = items
                if self.selectedCardId == nil {
                    self.selectedCardId = items.first?.id
                }
            }
            .store(in: &cancellables)
    }

    var selectedCard: BankCard? {
        cards.first { $0.id == selectedCardId }
    }

    func select(_ card: BankCard) { selectedCardId = card.id }
}
