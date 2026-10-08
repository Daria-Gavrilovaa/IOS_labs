//
//  ContentView.swift
//  BankingApp
//
//  Created by MAC on 05.09.26.
//

//
//  ContentView.swift
//  BankingApp
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var cardsVM: CardsViewModel
    @ObservedObject var transactionsVM: TransactionsViewModel
    @ObservedObject var statisticsVM: StatisticsViewModel

    var body: some View {
        TabView {
            CardsScreen(
                cardsVM: cardsVM,
                transactionsVM: transactionsVM
            )
            .tabItem {
                Label("Home", systemImage: "house")
            }

            PieChartView(viewModel: statisticsVM)
                .tabItem {
                    Label("Statistics", systemImage: "chart.pie")
                }
        }
    }
}
