//
//  CardRepository.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation
import Combine
import CoreData

protocol CardRepositoryProtocol {
    func fetchAll() -> AnyPublisher<[BankCard], Never>
    func seedIfNeeded() -> AnyPublisher<Void, Error>
}

final class CoreDataCardRepository: CardRepositoryProtocol {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }

    func fetchAll() -> AnyPublisher<[BankCard], Never> {
        Deferred { [context] in
            Future<[BankCard], Never> { promise in
                context.perform {
                    do {
                        let items = try context.fetch(BankCard.fetchRequest())
                        print("🟦 CardRepo.fetchAll → \(items.count)")
                        promise(.success(items))
                    } catch {
                        print("🟥 CardRepo.fetchAll ERROR: \(error)")
                        promise(.success([]))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func seedIfNeeded() -> AnyPublisher<Void, Error> {
        Deferred { [context] in
            Future<Void, Error> { promise in
                context.perform {
                    do {
                        let count = try context.count(for: BankCard.fetchRequest())
                        print("🟨 CardRepo.seedIfNeeded: count = \(count)")
                        if count == 0 {
                            let seeds: [(String, Double, Int)] = [
                                ("USD", 2156.63, 2745),
                                ("USD", 581.04,  1068),
                                ("USD", 10437.43, 5319),
                                ("USD", 246.81,  4001)
                            ]
                            for s in seeds {
                                _ = BankCard.create(
                                    in: context,
                                    currency: s.0,
                                    balance: s.1,
                                    lastNumbers: s.2
                                )
                            }
                            if context.hasChanges { try context.save() }
                            print("🟩 CardRepo.seedIfNeeded: засеяно 4 карты")
                        }
                        promise(.success(()))
                    } catch {
                        print("🟥 CardRepo.seedIfNeeded ERROR: \(error)")
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}
