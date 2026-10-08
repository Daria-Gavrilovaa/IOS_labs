//
//  CardView.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import SwiftUI

struct CardView: View {
    let card: BankCard
    var isSelected: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(card.iconName)
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 40)
            }
            Spacer()
            Text("Balance")
                .foregroundColor(isSelected ? .white : .black)
                .font(.caption)
            HStack {
                Text(card.currency)
                    .foregroundColor(isSelected ? .white : .black)
                    .font(.caption)
                Text(String(format: "%.2f", card.balance))
                    .foregroundColor(isSelected ? .white : .black)
                    .font(.headline).bold()
            }
            .padding(.bottom, 5)
            Text("**** **** **** \(card.lastNumbers)")
                .foregroundColor(isSelected ? .white : .black)
                .font(.caption)
                .padding(.vertical)
        }
        .padding(8)
        .background(isSelected ? Color("newBlue") : Color("White"))
        .cornerRadius(20)
        .frame(width: 200, height: 150)
    }
}
