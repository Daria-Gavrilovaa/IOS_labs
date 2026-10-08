//
//  BankCard.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation
import CoreData

@objc(BankCard)
public final class BankCard: NSManagedObject {

    @NSManaged public var id: UUID
    @NSManaged public var currency: String
    @NSManaged public var balance: Double
    @NSManaged public var lastNumbers: Int32
    @NSManaged public var iconName: String

    public var displayName: String { "•••• \(lastNumbers)" }
}

extension BankCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BankCard> {
        NSFetchRequest<BankCard>(entityName: "BankCard")
    }

    static func create(
        in context: NSManagedObjectContext,
        currency: String,
        balance: Double,
        lastNumbers: Int,
        iconName: String = "vizaIcon"
    ) -> BankCard {
        let c = BankCard(context: context)
        c.id = UUID()
        c.currency = currency
        c.balance = balance
        c.lastNumbers = Int32(lastNumbers)
        c.iconName = iconName
        return c
    }
}

extension BankCard: Identifiable {}
