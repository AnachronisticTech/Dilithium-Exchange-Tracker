//
//  LineChartSwiftUIView.swift
//  DilExTracker (macOS)
//
//  Created by Daniel Marriner on 24/07/2021.
//

import SwiftUI
import Charts

struct LineChartSwiftUIView: NSViewRepresentable {
    let data: [(Date, Int)]

    func makeNSView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.scaleYEnabled = false
        let dataSet = generateDataSet()
        chart.data = LineChartData(dataSet: dataSet)
        chart.xAxis.valueFormatter = ChartFormatter(with: dataSet)
        return chart
    }

    func updateNSView(_ nsView: LineChartView, context: Context) {
        let dataSet = generateDataSet()
        nsView.data = LineChartData(dataSet: dataSet)
        nsView.xAxis.valueFormatter = ChartFormatter(with: dataSet)
    }
}

struct LineChartSwiftUIView_Previews: PreviewProvider {
    static let formatter : DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyy MMMM dd"
        return df
    }()

    static var previews: some View {
        LineChartSwiftUIView(data: [
            (formatter.date(from: "2021 June 01")!, 489),
            (formatter.date(from: "2021 June 02")!, 489),
            (formatter.date(from: "2021 June 03")!, 488),
            (formatter.date(from: "2021 June 04")!, 488),
            (formatter.date(from: "2021 June 05")!, 493),
        ])
    }
}
