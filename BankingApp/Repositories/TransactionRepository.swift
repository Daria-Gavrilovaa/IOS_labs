//
//  TransactionRepository.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation
import Combine
import CoreData

protocol TransactionRepositoryProtocol {
    func fetchAll() -> AnyPublisher<[Transaction], Never>
    func save(_ dtos: [TransactionDTO],
              accountId: UUID,
              mccDirectory: MCCDirectoryProtocol) -> AnyPublisher<[Transaction], Error>
    func deleteAll() -> AnyPublisher<Void, Error>
}

final class CoreDataTransactionRepository: TransactionRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    func fetchAll() -> AnyPublisher<[Transaction], Never> {
        Deferred { [context] in
            Future<[Transaction], Never> { promise in
                context.perform {
                    do {
                        let req = Transaction.fetchRequest()
                        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                        let items = try context.fetch(req)
                        promise(.success(items))
                    } catch {
                        promise(.success([]))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func save(
        _ dtos: [TransactionDTO],
        accountId: UUID,
        mccDirectory: MCCDirectoryProtocol
    ) -> AnyPublisher<[Transaction], Error> {
        Deferred { [context] in
            Future<[Transaction], Error> { promise in
                context.perform {
                    do {
                        let iso = ISO8601DateFormatter()
                        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        let isoNoFrac = ISO8601DateFormatter()

                        var created: [Transaction] = []

                        for dto in dtos {
                            let category = mccDirectory.category(for: dto.mcc) ?? "Other"
                            let date = iso.date(from: dto.date)
                                ?? isoNoFrac.date(from: dto.date)
                                ?? Date()

                            let tx = Transaction.create(
                                in: context,
                                currency: dto.currency,
                                amount: dto.amount,
                                category: category,
                                merchant: dto.merchant,
                                mccCode: dto.mcc,
                                accountId: accountId,
                                date: date
                            )
                            created.append(tx)
                        }

                        if context.hasChanges {
                            try context.save()
                        }
                        promise(.success(created))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteAll() -> AnyPublisher<Void, Error> {
        Deferred { [context] in
            Future<Void, Error> { promise in
                context.perform {
                    do {
                        let all = try context.fetch(Transaction.fetchRequest())
                        all.forEach { context.delete($0) }
                        if context.hasChanges { try context.save() }
                        promise(.success(()))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
