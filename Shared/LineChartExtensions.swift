//
//  LineChartExtensions.swift
//  DilExTracker
//
//  Created by Daniel Marriner on 24/07/2021.
//

import Foundation
import Charts

extension LineChartSwiftUIView {
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
