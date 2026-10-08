//
//  PieChartView.swift
//  BankingApp
//
//  Created by MAC on 27.09.26.
//

import SwiftUI

struct PieChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    private let colors: [Color] = [.blue, .red, .green, .orange, .purple, .indigo]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.slices.isEmpty {
                    Text("No transactions")
                        .foregroundColor(.secondary)
                } else {
                    chart.frame(height: 250)
                    legend
                }
            }
            .padding()
            .navigationTitle("Statistics")
        }
    }

    private var chart: some View {
        Canvas { ctx, size in
            let total = viewModel.total
            guard total > 0 else { return }
            let radius = min(size.width, size.height) * 0.4
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            var start = Angle(degrees: -90)

            for (i, slice) in viewModel.slices.enumerated() {
                let angle = Angle(degrees: 360 * slice.total / total)
                let end = start + angle

                var path = Path()
                path.move(to: center)
                path.addArc(center: center, radius: radius,
                            startAngle: start, endAngle: end,
                            clockwise: false)
                path.closeSubpath()

                ctx.fill(path, with: .color(colors[i % colors.count]))
                start = end
            }
        }
    }

    private var legend: some View {
        VStack(spacing: 10) {
            ForEach(Array(viewModel.slices.enumerated()), id: \.offset) { i, slice in
                HStack {
                    Circle().fill(colors[i % colors.count])
                        .frame(width: 12, height: 12)
                    Text(slice.category).font(.caption)
                    Spacer()
                    Text(String(format: "%.2f", slice.total))
                        .font(.caption).foregroundColor(.secondary)
                }
            }
        }
    }
}
