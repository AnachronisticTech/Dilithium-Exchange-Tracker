//
//  LineChartSwiftUIView.swift
//  DilExTracker (iOS)
//
//  Created by Daniel Marriner on 26/06/2021.
//

import SwiftUI
import Charts

struct LineChartSwiftUIView: UIViewRepresentable {
    let data: [(Date, Int)]

    func makeUIView(context: Context) -> LineChartView {
        let chart = LineChartView()
        chart.scaleYEnabled = false
        let dataSet = generateDataSet()
        chart.data = LineChartData(dataSet: dataSet)
        chart.xAxis.valueFormatter = ChartFormatter(with: dataSet)
        return chart
    }

    func updateUIView(_ uiView: LineChartView, context: Context) {
        let dataSet = generateDataSet()
        uiView.data = LineChartData(dataSet: dataSet)
        uiView.xAxis.valueFormatter = ChartFormatter(with: dataSet)
    }
}

struct LineChartSwiftUIView_Preview: PreviewProvider {
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
