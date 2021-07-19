//
//  LineChartSwiftUIView.swift
//  DilExTracker (iOS)
//
//  Created by Daniel Marriner on 26/06/2021.
//

import SwiftUI
import OrderedCollections
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

    func generateDataSet() -> LineChartDataSet {
        let dataSet = LineChartDataSet(
            entries: data
                .enumerated()
                .map { index, entry in
                    ChartDataEntry(
                        x: Double(index),
                        y: Double(entry.1),
                        data: entry.0
                    )
                }
        )
        dataSet.label = "Dilithium per Zen"
        dataSet.colors = [NSUIColor(red: 194/255, green: 70/255, blue: 205/255, alpha: 1)]
        dataSet.circleColors = [NSUIColor(red: 194/255, green: 70/255, blue: 205/255, alpha: 1)]
        dataSet.circleRadius = 3
        return dataSet
    }

    class ChartFormatter: IndexAxisValueFormatter {
        private var data: [ChartDataEntry]?

        private var formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("d MMM yy")
            return formatter
        }()

        convenience init(with dataSet: LineChartDataSet) {
            self.init()
            self.data = dataSet.entries
        }

        override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let index = Int(value)
            guard
                let data = data,
                index < data.count,
                let date = data[index].data as? Date
            else {
                return "?"
            }
            return formatter.string(from: date)
        }
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
