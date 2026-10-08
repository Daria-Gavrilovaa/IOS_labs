//
//  MCCCode.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import Foundation

struct MCCCode: Codable, Identifiable, Hashable {
    var id: String { code }
    let code: String
    let category: String
    let description: String
}
