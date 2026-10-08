//
//  Transaction.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation
import CoreData

@objc(Transaction)
public final class Transaction: NSManagedObject {

    @NSManaged public var id: UUID
    @NSManaged public var currency: String
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var merchant: String
    @NSManaged public var mccCode: String?
    @NSManaged public var accountId: UUID?
    @NSManaged public var date: Date
    @NSManaged public var iconName: String
}

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    static func create(
        in context: NSManagedObjectContext,
        currency: String,
        amount: Double,
        category: String,
        merchant: String,
        mccCode: String?,
        accountId: UUID?,
        date: Date,
        iconName: String = "vizaIcon"
    ) -> Transaction {
        let tx = Transaction(context: context)
        tx.id = UUID()
        tx.currency = currency
        tx.amount = amount
        tx.category = category
        tx.merchant = merchant
        tx.mccCode = mccCode
        tx.accountId = accountId
        tx.date = date
        tx.iconName = iconName
        return tx
    }
}

extension Transaction: Identifiable {}

/// DTO для импорта из JSON — отдельный тип, не вложенный
struct TransactionDTO: Codable {
    let currency: String
    let amount: Double
    let merchant: String
    let mcc: String
    let date: String
    let accountLast4: Int?
}
