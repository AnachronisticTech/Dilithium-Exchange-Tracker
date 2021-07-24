//
//  DilExManager.swift
//  DilExTracker
//
//  Created by Daniel Marriner on 18/07/2021.
//

import Foundation
import Combine
import OrderedCollections

protocol DilExModel: Decodable {
    var data: [String: OrderedDictionary<String, [(Int, ExchangeState)]>] { get }
}

enum TimeRange: String, CaseIterable {
    case week = "1W"
    case month = "1M"
    case month3 = "3M"
    case year = "1Y"
    case year3 = "3Y"
    case all = "All"

    var days: Int {
        switch self {
            case .week: return 7
            case .month: return 30
            case .month3: return 90
            case .year: return 365
            case .year3: return 365 * 3
            case .all: return Int.max
        }
    }
}

enum ExchangeState: CustomStringConvertible {
    case invalidData
    case backlogged
    case value(Int)
    case range(Int, Int)

    var description: String {
        switch self {
            case .invalidData: return "Data unavailable"
            case .backlogged: return "Empty due to backlog"
            case .value(let v): return "VALUE: \(v)"
            case .range(let l, let h): return "HIGH: \(h), LOW: \(l), AVE: \(Int((l + h) / 2))"
        }
    }
}

class DilExManager: ObservableObject {
    private init(data: [String: OrderedDictionary<String, [(Int, ExchangeState)]>] = [:]) {
        self.data = data
    }

    static var shared = DilExManager()

    static var preview = DilExManager(data: [
        "2021": [
            "January": [(1, .value(25)), (2, .value(50)), (3, .value(75)), (4, .value(100))],
            "February": [(1, .value(125)), (2, .value(150)), (3, .value(175)), (4, .value(110))]
        ]
        ,
        "2020": [
            "March": [(1, .value(25)), (2, .invalidData), (3, .range(75, 80)), (4, .backlogged)]
        ]
    ])

    @Published
    public private(set) var data: [String: OrderedDictionary<String, [(Int, ExchangeState)]>] = [:]

    public var projectedData: OrderedDictionary<Date, Int> {
        let formatter: DateFormatter = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.timeZone = TimeZone(abbreviation: "UTC")
            df.dateFormat = "dd MMMM yyy"
            return df
        }()

        return data
            .sorted(by: { $0.key < $1.key })
            .flatMap { year, months in
                months.elements.flatMap { month, days in
                    days.compactMap { (day, data) -> (Date, Int)? in
                        switch data {
                            case .value(let v): return (formatter.date(from: "\(day) \(month) \(year)")!, v)
                            case .range(let l, let h): return (formatter.date(from: "\(day) \(month) \(year)")!, Int((l + h) / 2))
                            default: return nil
                        }
                    }
                }
            }
            .reduce(OrderedDictionary<Date, Int>()) { dict, entry in
                var dict = dict
                dict[entry.0] = entry.1
                return dict
            }
    }

    func fetchData() {
        data = [:]
        let semaphore = DispatchSemaphore(value: 2)

        let post2019Url = URL(string: """
        https://sheets.googleapis.com/v4/spreadsheets/
        1d8en4AFHupjRkwldCRICiQJVIIkJCJqjKTCwBh7GweY/
        values:batchGet
        ?key=\(Constants.apiKey)
        &ranges=2019!B4:M33
        &ranges=2020!B2:M33
        &ranges=2021!B2:M33
        &majorDimension=COLUMNS
        """.replacingOccurrences(of: "\n", with: ""))!
        fetchData(from: post2019Url, decodingWith: FraserModel.self) {
            semaphore.signal()
        }

        let pre2019Url = URL(string: """
        https://sheets.googleapis.com/v4/spreadsheets/
        1u82v-JbO0vyFXsEw2eORD0RY5tRov7lXgzEuvCKxo9s/
        values/Exchange%20Log!A7:B1782
        ?key=\(Constants.apiKey)
        """.replacingOccurrences(of: "\n", with: ""))!
        fetchData(from: pre2019Url, decodingWith: Z8Model.self) {
            semaphore.signal()
        }

        semaphore.wait()
    }

    private func fetchData<T>(
        from url: URL,
        decodingWith type: T.Type,
        completionHandler: () -> () = {}
    ) where T: DilExModel {
        let semaphore = DispatchSemaphore(value: 0)
        URLSession
            .shared
            .dataTask(with: url) { data, _, _ in
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let decoded = try decoder.decode(type.self, from: data).data
                         DispatchQueue.main.async {
                            self.data.merge(decoded) { old, _ in old }
                         }
                    } catch {
                        print("Couldn't decode")
                    }
                }
                semaphore.signal()
            }
            .resume()
        semaphore.wait()
        completionHandler()
    }

    private struct FraserModel: DilExModel {
        private let valueRanges: [Year]

        var data: [String: OrderedDictionary<String, [(Int, ExchangeState)]>] {
            return valueRanges
                .reduce([:]) { dict, yearData in
                    var dict = dict
                    dict[yearData.year] = yearData.data
                    return dict
                }
        }

        struct Year: Decodable {
            private let range: String
            private let values: [[String]]

            var year: String { String(range.split(separator: "'")[0]) }

            var data: OrderedDictionary<String, [(Int, ExchangeState)]> {
                return values
                    .reduce([:]) { dict, values in
                        var dict = dict
                        if values.count == 1 { return dict }
                        dict[values[0]] = Array(
                            values
                                .filter({ !$0.contains("--") })
                                .map { entry -> ExchangeState in
                                    if entry.contains("Empty") { return .backlogged }
                                    if !entry.contains("-") {
                                        guard let value = Int(entry) else { return .invalidData }
                                        return .value(value)
                                    } else {
                                        let values = entry
                                            .split(separator: "-")
                                            .map({ String($0) })
                                        guard
                                            let first = values.first,
                                            let last = values.last,
                                            let lBound = Int(first),
                                            let rBound = Int(last),
                                            lBound <= rBound
                                        else { return .invalidData }
                                        return .range(lBound, rBound)
                                    }
                                }
                                .enumerated()
                                .dropFirst()
                        )
                        return dict
                    }
            }
        }
    }

    private struct Z8Model: DilExModel {
        let values: [[String]]

        var data: [String: OrderedDictionary<String, [(Int, ExchangeState)]>] {
            return values
                .reduce([:]) { dict, entry in
                    var dict = dict
                    let dateComponents = entry[0]
                        .split(separator: "/")
                        .map { String($0) }

                    guard
                        dateComponents.count == 3,
                        let day = Int(dateComponents[1])
                    else { return dict }
                    let year = dateComponents[2]
                    let month = month(from: dateComponents[0])
                    let value = Int(entry[1])
                    let state: ExchangeState = value != nil ? .value(value!) : .invalidData

                    if dict[year] == nil {
                        dict[year] = [:]
                    }
                    if dict[year]![month] == nil {
                        dict[year]![month] = []
                    }
                    dict[year]![month]!.append((day, state))
                    return dict
                }
        }

        func month(from stringNumber: String) -> String {
            switch stringNumber {
                case "1": return "January"
                case "2": return "February"
                case "3": return "March"
                case "4": return "April"
                case "5": return "May"
                case "6": return "June"
                case "7": return "July"
                case "8": return "August"
                case "9": return "September"
                case "10": return "October"
                case "11": return "November"
                default: return "December"
            }
        }
    }
}

