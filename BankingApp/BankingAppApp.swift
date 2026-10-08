//
//  BankingAppApp.swift
//  BankingApp
//
//  Created by MAC on 03.09.26.
//

import SwiftUI
import CoreData

@main
struct BankingAppApp: App {

    @StateObject private var cardsVM: CardsViewModel
    @StateObject private var transactionsVM: TransactionsViewModel
    @StateObject private var statisticsVM: StatisticsViewModel

    private let stack = CoreDataStack.shared

    init() {
        let mccDirectory: MCCDirectoryProtocol = MCCDirectoryService()
        let importer: TransactionImportProtocol = TransactionImportService()

        let txRepo: TransactionRepositoryProtocol =
            CoreDataTransactionRepository(context: stack.viewContext)
        let cardRepo: CardRepositoryProtocol =
            CoreDataCardRepository(context: stack.viewContext)

        let txVM = TransactionsViewModel(
            importService: importer,
            transactionRepo: txRepo,
            mccDirectory: mccDirectory
        )
        let cardsVM = CardsViewModel(cardRepo: cardRepo)
        let statsVM = StatisticsViewModel(transactionsVM: txVM)

        _transactionsVM = StateObject(wrappedValue: txVM)
        _cardsVM = StateObject(wrappedValue: cardsVM)
        _statisticsVM = StateObject(wrappedValue: statsVM)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                cardsVM: cardsVM,
                transactionsVM: transactionsVM,
                statisticsVM: statisticsVM
            )
            .environment(\.managedObjectContext, stack.viewContext)
        }
    }
}
