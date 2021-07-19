//
//  DataView.swift
//  DilExTracker (iOS)
//
//  Created by Daniel Marriner on 25/06/2021.
//

import SwiftUI

struct DataView: View {
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

    @State private var timeRange: TimeRange = .week
    @ObservedObject private var manager = DilExManager.shared

    var body: some View {
        VStack {
            if !manager.data.isEmpty {
                NavigationView {
                    if idiom == .pad {
                        List {
                            ForEach(manager.data.sorted(by: { $0.key > $1.key }), id: \.key) { year, months in
                                ForEach(months.elements.reversed(), id: \.key) { month, days in
                                    Section(header: Text("\(year), \(month)")) {
                                        ForEach(days.reversed(), id: \.0) { day, data in
                                            HStack {
                                                Text("\(day)")
                                                Spacer()
                                                Text("\(data.description)")
                                                    .font(.system(size: 14, design: .monospaced))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        LineChartSwiftUIView(data: Array(manager.projectedData.elements.suffix(timeRange.days)))
                            .padding(.horizontal)
                    } else {
                        VStack {
                            Picker("", selection: $timeRange) {
                                ForEach(TimeRange.allCases, id: \.self) { range in
                                    Text("\(range.rawValue)")
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            LineChartSwiftUIView(data: Array(manager.projectedData.elements.suffix(timeRange.days)))
                                .padding(.horizontal)
                            List {
                                ForEach(manager.data.sorted(by: { $0.key > $1.key }), id: \.key) { year, months in
                                    ForEach(months.elements.reversed(), id: \.key) { month, days in
                                        Section(header: Text("\(year), \(month)")) {
                                            ForEach(days.reversed(), id: \.0) { day, data in
                                                HStack {
                                                    Text("\(day)")
                                                    Spacer()
                                                    Text("\(data.description)")
                                                        .font(.system(size: 14, design: .monospaced))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .navigationTitle("Price per Zen")
                    }
                }
            } else {
                ProgressView()
                    .scaleEffect(CGSize(width: 2, height: 2))
                    .padding()
                Text("Loading exchange rates")
            }
        }
        .onAppear {
            DilExManager.shared.fetchData()
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
