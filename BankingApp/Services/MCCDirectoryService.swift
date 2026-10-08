//
//  MCCDirectoryService.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation

protocol MCCDirectoryProtocol {
    func category(for code: String) -> String?
    func code(for code: String) -> MCCCode?
}

final class MCCDirectoryService: MCCDirectoryProtocol {

    private var directory: [String: MCCCode] = [:]

    init(bundle: Bundle = .main) {
        load(from: bundle)
    }

    private func load(from bundle: Bundle) {
        guard let url = bundle.url(forResource: "mcc_codes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let codes = try? JSONDecoder().decode([MCCCode].self, from: data)
        else {
            directory = Self.fallback
            return
        }
        directory = Dictionary(uniqueKeysWithValues: codes.map { ($0.code, $0) })
    }

    func category(for code: String) -> String? {
        directory[code]?.category
    }

    func code(for code: String) -> MCCCode? {
        directory[code]
    }

    private static let fallback: [String: MCCCode] = [
        "5411": MCCCode(code: "5411", category: "Groceries",   description: "Grocery Stores"),
        "5812": MCCCode(code: "5812", category: "Restaurants", description: "Eating Places"),
        "5814": MCCCode(code: "5814", category: "Fast Food",   description: "Fast Food"),
        "5999": MCCCode(code: "5999", category: "Retail",      description: "Misc. Retail"),
        "4814": MCCCode(code: "4814", category: "Telecom",     description: "Telecom Services"),
        "4111": MCCCode(code: "4111", category: "Transport",   description: "Transportation"),
        "5912": MCCCode(code: "5912", category: "Pharmacy",    description: "Drug Stores"),
        "7011": MCCCode(code: "7011", category: "Travel",      description: "Hotels")
    ]
}
