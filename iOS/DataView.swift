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

    @State private var isShowingSheet = false

    var body: some View {
        VStack {
            if !manager.data.isEmpty {
                NavigationView {
                    Group {
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
                            }
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
                        }
                    }
                    .navigationTitle("Price per Zen")
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Button {
                                isShowingSheet = true
                            } label: {
                                Image(systemName: "info.circle")
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                manager.fetchData()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                }
            } else {
                ProgressView()
                    .scaleEffect(CGSize(width: 2, height: 2))
                    .padding()
                Text("Loading exchange rates")
            }
        }
        .onAppear(perform: manager.fetchData)
        .sheet(isPresented: $isShowingSheet) {
            NavigationView {
                List {
                    Section(header: Text("Data sources")) {
                        Link(
                            "Dilithium Exchange (Google Sheets)",
                            destination: URL(string: "https://docs.google.com/spreadsheets/d/1d8en4AFHupjRkwldCRICiQJVIIkJCJqjKTCwBh7GweY")!
                        )
                        Link(
                            "STO Z8 Index (Google Sheets)",
                            destination: URL(string: "https://docs.google.com/spreadsheets/d/1u82v-JbO0vyFXsEw2eORD0RY5tRov7lXgzEuvCKxo9s")!
                        )
                    }
                    Section(header: Text("Libraries")) {
                        Link(
                            "Charts (GitHub, Apache-2.0)",
                            destination: URL(string: "https://github.com/danielgindi/Charts")!
                        )
                        Link(
                            "Swift Collections (GitHub, Apache-2.0)",
                            destination: URL(string: "https://github.com/apple/swift-collections")!
                        )
                    }
                }
                .navigationTitle("Attributions")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
