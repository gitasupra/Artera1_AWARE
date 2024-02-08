import Foundation
import Foundation
import SwiftCSV



class PredictLevel{


    enum Features: Int, CaseIterable, Codable {
        case Mean = 0
        case Median = 1
        case Std_Dev = 2
        case ZeroCrsRate = 3
        case Max_Raw = 4
        case Min_Raw = 5
        case Max_Abs = 6
        case Min_Abs = 7
        case Spec_Ent_Time = 8
        case Max_freq = 9
        case Skewness = 10
        case Kurtosis = 11
        case Avg_Power = 12
    }

    var FeatureType: [Features: String] = [


        .Mean: "Mean",
        .Median: "Median",
        .Std_Dev: "Std_Dev",
        .ZeroCrsRate: "ZeroCrsRate",
        .Max_Raw: "Max_Raw",
        .Min_Raw: "Min_Raw",
        .Max_Abs: "Max_Abs",
        .Min_Abs: "Min_Abs",
        .Spec_Ent_Time: "Spec_Ent_Time",
        .Skewness: "Skewness",
        .Kurtosis: "Kurtosis",
        .Avg_Power: "Avg_Power"
    ]

//    func separate_pid_data() -> [String] {
//        let accData = try! CSV<Named>(url: URL(fileURLWithPath: "data/all_accelerometer_data_pids_13.csv"))
//        let pids = Set(accData.rows.map { $0["pid"]! })
//        for pid in pids {
//            let df = accData.filter { $0["pid"]! == pid }
//            try! df.write(to: URL(fileURLWithPath: pid), encoding: .utf8)
//            print("\(pid).csv created")
//        }
//        print(pids)
//        return Array(pids)
//    }

    
    func zeroCrossingRate(_ values: [Double]) -> Double {
        var zeroCrossings = 0
        for i in 1..<values.count {
            if values[i] * values[i - 1] < 0 {
                zeroCrossings += 1
            }
        }
        return Double(zeroCrossings) / Double(values.count - 1)
    }
    
    func spectralEntropy(_ values: [Double]) -> Double {
        let n = values.count
        var counts: [Double: Int] = [:]
        
        // Count occurrences of each value
        for value in values {
            counts[value, default: 0] += 1
        }
        
        // Calculate probabilities
        var probabilities: [Double] = []
        for count in counts.values {
            let probability = Double(count) / Double(n)
            probabilities.append(probability)
        }
        
        // Calculate entropy
        var entropy = 0.0
        for probability in probabilities {
            entropy -= probability * log2(probability)
        }
        
        return entropy
    }


    func mean(_ values: [Double]) -> Double {
        return values.reduce(0, +) / Double(values.count)
    }

    func median(_ values: [Double]) -> Double {
        let sortedValues = values.sorted()
        let count = sortedValues.count
        if count % 2 == 0 {
            return (sortedValues[count / 2 - 1] + sortedValues[count / 2]) / 2
        } else {
            return sortedValues[count / 2]
        }
    }
    
    func variance(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        
        let meanValue = values.reduce(0, +) / Double(values.count)
        let squaredDifferences = values.map { pow($0 - meanValue, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(values.count)
        
        return variance
    }


    func standardDeviation(_ values: [Double]) -> Double {
        let meanValue = mean(values)
        let squaredDifferences = values.map { pow($0 - meanValue, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }

    func skewness(_ values: [Double]) -> Double {
        let meanValue = mean(values)
        let n = Double(values.count)
        let numerator = values.reduce(0) { $0 + pow(($1 - meanValue), 3) }
        let denominator = pow(standardDeviation(values), 3) * n
        return numerator / denominator
    }

    func kurtosis(_ values: [Double]) -> Double {
        let meanValue = mean(values)
        let n = Double(values.count)
        let numerator = values.reduce(0) { $0 + pow(($1 - meanValue), 4) }
        let denominator = pow(standardDeviation(values), 4) * n
        return numerator / denominator - 3
    }

    
    
    func createFileDirectoryIfNeeded(at url: URL) {
        let directoryURL = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    func create_per_second_data(pidFilename: String, metricNo: Int) -> String {
        let accData = try! CSV<Named>(url: URL(fileURLWithPath: pidFilename))
        var prevTs = 0
        var fullFrame: [[Double]] = []
        var subFrame: [[Double]] = []
        let totRows = accData.rows.count
        
        for idx in 0..<totRows {
            if idx % 10000 == 0 { print(idx, "**") }
            let row = accData.rows[idx]
            let currTs = Int(row["time"]!)! % 1000
            if idx != 0 { prevTs = Int(accData.rows[idx-1]["time"]!)! % 1000 }
            if currTs > prevTs {
                subFrame.append([Double(row["time"]!)!, Double(row["x"]!)!, Double(row["y"]!)!, Double(row["z"]!)!])
            } else {
                subFrame = subFrame.map { $0.map { Double($0) } }
                var metricsAxis: [Double] = []
                
                metricsAxis.append(subFrame.last![0])
                
                for col in 1...3 {
                    switch Features(rawValue: metricNo)! {
                        case .Mean:
                            metricsAxis.append(mean(subFrame.map { $0[col] }))
                        case .Median:
                            metricsAxis.append(median(subFrame.map { $0[col] }))
                        case .Std_Dev:
                            metricsAxis.append(standardDeviation(subFrame.map { $0[col] }))
                        case .ZeroCrsRate:
                            metricsAxis.append(zeroCrossingRate(subFrame.map { $0[col] }))
                        case .Max_Raw:
                            metricsAxis.append(subFrame.map { $0[col] }.max()!)
                        case .Min_Raw:
                            metricsAxis.append(subFrame.map { $0[col] }.min()!)
                        case .Max_Abs:
                            metricsAxis.append(subFrame.map { abs($0[col]) }.max()!)
                        case .Min_Abs:
                            metricsAxis.append(subFrame.map { abs($0[col]) }.min()!)
                        case .Spec_Ent_Time:
                            metricsAxis.append(spectralEntropy(subFrame.map { $0[col] }))
                        case .Skewness:
                            metricsAxis.append(skewness(subFrame.map { $0[col] }))
                        case .Kurtosis:
                            metricsAxis.append(kurtosis(subFrame.map { $0[col] }))
                        default:
                            break
                    }
                }
                fullFrame.append(metricsAxis)
                subFrame = []
            }
        }
        
        guard let feature = Features(rawValue: metricNo) else {
            // Handle the case where Features(rawValue: metricNo) is nil
            print("Invalid metric number: \(metricNo)")
            return ""
        }
        if let featureName = FeatureType[Features(rawValue: metricNo)!] {
            let filename = "\(featureName)_all_per_sec_all_axis.json"
            guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename) else {
                print("Failed to create file URL")
                return ""
            }
            
        createFileDirectoryIfNeeded(at: fileURL)
            
            
            
            
            do {
                let jsonData = try JSONEncoder().encode(fullFrame)
                try jsonData.write(to: fileURL, options: .atomic) // Use .atomic option to ensure that the write operation is atomic
                print("Full Frame Shape - \(fullFrame.count)x\(fullFrame[0].count)")
            } catch {
                print("Error writing JSON data: \(error)")
            }
            print(fileURL.path)
            return fileURL.path
            
            
        } else {
            print("Feature name not found for metric number \(metricNo)")
            // Handle the case where the feature name is not found
            return ""
        }



    }
    
    func create_per_window_data(pidFilename: String, metricNo: Int) -> String {
        do {
            // Read the CSV file using SwiftCSV
            let csvFile = try CSV<Named>(url: URL(fileURLWithPath: pidFilename))
            
            // Extract data from the CSV file
            var mean_all: [[Double]] = []
            for row in csvFile.rows {
                let rowData: [Double] = [Double(row["timestamp"]!)!, Double(row["x"]!)!, Double(row["y"]!)!, Double(row["z"]!)!]
                mean_all.append(rowData)
            }
            
            // Perform calculations for each 10-second window
            var full_frame: [[Double]] = []
            var single_row: [Double] = []
            var i = 0
            let tot_rows = mean_all.count
            
            while i + 10 < tot_rows {
                single_row.append(mean_all[i+9][0])
                for col in 1...3 {
                    let sub_frame = mean_all[i..<i+10].map { $0[col] }
                    single_row.append(sub_frame.reduce(0, +) / Double(sub_frame.count))
                    single_row.append(variance(sub_frame))
                    single_row.append(sub_frame.max()!)
                    single_row.append(sub_frame.min()!)
                    let sorted_sub_frame = sub_frame.sorted()
                    single_row.append(Array(sorted_sub_frame[0..<4]).reduce(0, +) / 4)
                    single_row.append(Array(sorted_sub_frame[8..<11]).reduce(0, +) / 3)
                }
                full_frame.append(single_row)
                single_row = []
                i += 10
            }
            
            // Write the data to a new CSV file
            let outputFileName = "Metric_\(metricNo)_window.csv"
            guard let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(outputFileName) else {
                print("Failed to create file URL")
                return ""
            }
            
            createFileDirectoryIfNeeded(at: fileURL)

            do {
                let jsonData = try JSONEncoder().encode(full_frame)
                try jsonData.write(to: fileURL, options: .atomic) // Use .atomic option to ensure that the write operation is atomic
                return fileURL.path
            } catch {
                print("Error writing JSON data: \(error)")
                return ""
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return ""
        }
    }

    
    func processData(pidFilename: String) -> String {
        var perWindowDataFile : String = ""
        for metricNo in Features.allCases.map({ $0.rawValue }) {
            let perSecondDataFile = create_per_second_data(pidFilename: pidFilename, metricNo: metricNo)
            perWindowDataFile = create_per_window_data(pidFilename: perSecondDataFile, metricNo: metricNo)

            // You may perform further operations with the generated files if needed
        }
        return perWindowDataFile
    }

}
