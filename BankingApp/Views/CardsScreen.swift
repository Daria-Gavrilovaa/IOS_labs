//
//  CardsScreen.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import SwiftUI

struct CardsScreen: View {
    @ObservedObject var cardsVM: CardsViewModel
    @ObservedObject var transactionsVM: TransactionsViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color("newWhite").ignoresSafeArea()
                ScrollView {
                    CardList(viewModel: cardsVM)
                    TransactionsView(
                        viewModel: transactionsVM,
                        cards: cardsVM.cards,
                        preferredAccountId: cardsVM.selectedCardId
                    )
                }
                .navigationTitle("My Card")
            }
        }
    }
}
