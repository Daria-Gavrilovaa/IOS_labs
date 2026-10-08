//
//  CardList.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import SwiftUI

struct CardList: View {
    @ObservedObject var viewModel: CardsViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.cards) { card in
                    CardView(card: card,
                             isSelected: card.id == viewModel.selectedCardId)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 5)
                        .onTapGesture { viewModel.select(card) }
                }
            }
            .padding(20)
        }
    }
}
