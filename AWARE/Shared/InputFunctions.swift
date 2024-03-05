//
//  InputFunctions.swift
//  AWARE
//
//  Created by Gita Supramaniam on 2/10/24.
//

import Foundation
import SwiftCSV
import TabularData
import CSV

class InputFunctions : ObservableObject{
    enum Features: Int, CaseIterable {
        case Mean = 0
        case Median = 1
        case Std_Dev = 2
        case Max_Raw = 4
        case Min_Raw = 5
        case Max_Abs = 6
        case Min_Abs = 7
    }

    var FeatureType: [Features: String] = [
        .Mean : "Mean",
        .Median : "Median",
        .Std_Dev : "Std_Dev",
        .Max_Raw  : "Max_Raw",
        .Min_Raw : "Min_Raw",
        .Max_Abs : "Max_Abs",
        .Min_Abs : "Min_Abs",
    ]
    
    // helper function to calculate the mean
    func calculateMean(values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil // Return nil for an empty array
        }
        
        let sum = values.reduce(0, +)
        let mean = sum / Double(values.count)
        
        return mean
    }
    
    // helper function to calculate the median
    func calculateMedian(values: [Double]) -> Double? {
        guard !values.isEmpty else {
            return nil // Return nil for an empty array
        }
        
        let sortedValues = values.sorted()
        let count = sortedValues.count
        
        if count % 2 == 0 {
            // For an even number of elements, take the average of the two middle values
            let middle1 = sortedValues[count / 2 - 1]
            let middle2 = sortedValues[count / 2]
            return (middle1 + middle2) / 2.0
        } else {
            // For an odd number of elements, return the middle value
            return sortedValues[count / 2]
        }
    }
    
    // helper function to calculate the standard deviation
    func calculateStandardDeviation(values: [Double]) -> Double? {
        guard let mean = calculateMean(values: values) else {
            return nil // Return nil if mean calculation fails
        }
        
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let sumOfSquaredDifferences = squaredDifferences.reduce(0, +)
        let variance = sumOfSquaredDifferences / Double(values.count)
        let standardDeviation = sqrt(variance)
        
        return standardDeviation
    }
    
    // helper function to calculate minimum value
    func calculateMinimum(values: [Double]) -> Double? {
        guard let minValue = values.min() else {
            return nil // Return nil for an empty array
        }
        return minValue
    }
    
    // helper function to calculate maximum value
    func calculateMaximum(values: [Double]) -> Double? {
        guard let maxValue = values.max() else {
            return nil // Return nil for an empty array
        }
        return maxValue
    }
    
    // helper function to calculate variance
    func calculateVariance(values: [Double]) -> Double? {
        guard let mean = calculateMean(values: values) else {
            return nil // Return nil if mean calculation fails
        }
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let sumOfSquaredDifferences = squaredDifferences.reduce(0, +)
        let variance = sumOfSquaredDifferences / Double(values.count)
        return variance
    }
    
    func combine_features(csvPath: String) -> String? {
        let metric_no=0;
        let csvFileName = "/Metric_0_36.csv"
        
        let csvURL = URL(fileURLWithPath: csvPath + csvFileName)
        let csvFile = try? SwiftCSV.CSV<Named>(url: csvURL)
        
        do {
            // Manually define column types based on your data
            let columnTypes: [String: CSVType] = [
                "t": .string,   // Assuming timestamp is of type String
                "\(metric_no)xMe": .double,
                "\(metric_no)xVr": .double,
                "\(metric_no)xMx": .double,
                "\(metric_no)xMi": .double,
                "\(metric_no)xUM": .double,
                "\(metric_no)xLM": .double,
                "\(metric_no)yMe": .double,
                "\(metric_no)yVr": .double,
                "\(metric_no)yMx": .double,
                "\(metric_no)yMn": .double,
                "\(metric_no)yUM": .double,
                "\(metric_no)yLM": .double,
                "\(metric_no)zMe": .double,
                "\(metric_no)zVr": .double,
                "\(metric_no)zMx": .double,
                "\(metric_no)zMi": .double,
                "\(metric_no)zUM": .double,
                "\(metric_no)zLM": .double,
                // Add other columns and their types as needed
            ]
            
            var df = try! DataFrame(
                contentsOfCSVFile: csvURL,
                columns: csvFile?.header,
                rows: nil, // You can specify a range of rows if needed
                types: columnTypes
            )
            
            // if want to add more features, fix the range of the loop
            for i in 1..<8 where i != 3 {
                let fileName: String
                if i < 14 {
                    fileName = "/Metric_\(i)_36.csv"
                } else {
                    fileName = "/Metric_\(i)_18.csv"
                }
                
                let fileURL = URL(fileURLWithPath: csvPath + fileName)
                let fileCSV = try? SwiftCSV.CSV<Named>(url: fileURL)

                // Assuming the columns in fileCSV have similar types to the original CSV
                let finalColumnTypes: [String: CSVType] = [
                    "t": .string,   // Assuming timestamp is of type String
                    "\(i)xMe": .double,
                    "\(i)xVr": .double,
                    "\(i)xMx": .double,
                    "\(i)xMi": .double,
                    "\(i)xUM": .double,
                    "\(i)xLM": .double,
                    "\(i)yMe": .double,
                    "\(i)yVr": .double,
                    "\(i)yMx": .double,
                    "\(i)yMn": .double,
                    "\(i)yUM": .double,
                    "\(i)yLM": .double,
                    "\(i)zMe": .double,
                    "\(i)zVr": .double,
                    "\(i)zMx": .double,
                    "\(i)zMi": .double,
                    "\(i)zUM": .double,
                    "\(i)zLM": .double,
                    // Add other columns and their types as needed
                ]
                
                let joinColumns = [
                    "t",
                    "\(i)xMe", "\(i)xVr", "\(i)xMx", "\(i)xMi", "\(i)xUM", "\(i)xLM",
                    "\(i)yMe", "\(i)yVr", "\(i)yMx", "\(i)yMn", "\(i)yUM", "\(i)yLM",
                    "\(i)zMe", "\(i)zVr", "\(i)zMx", "\(i)zMi", "\(i)zUM", "\(i)zLM"
                ]
                
                let x = try! DataFrame(
                    contentsOfCSVFile: fileURL,
                    columns: fileCSV?.header,
                    rows: nil, // You can specify a range of rows if needed
                    types: finalColumnTypes
                )
                df = try! df.joined(x, on: ("t", "t"), kind: .inner)
            }
            df.removeColumn("t")
            for column in df.columns.map ({ col in col.name })  {
                let newColumnName = column.replacingOccurrences(of: "left.", with: "").replacingOccurrences(of: "right.", with: "")
                df.renameColumn(column, to: newColumnName)// Assuming you can access column data like this
            }
            
            let outputFileName = "/X.csv"
            let outputURL = URL(fileURLWithPath: csvPath + outputFileName)
            
            do {
                try df.writeCSV(to: outputURL)
                print("Combined DataFrame saved to CSV: \(outputURL.path)")
                return outputURL.path
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        } catch {
            print("Error:\(error.localizedDescription)")
        }
        return nil
    }
    
    func createFileDirectoryIfNeeded(at url: URL) {
        let directoryURL = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    func create_per_second_data(file: String, metric_no: Int) -> String {
        // Read the CSV file using SwiftCSV
        do {
            let csvFile = try! SwiftCSV.CSV<Named>(url: URL(fileURLWithPath: file))
            
            // Extract data from the CSV file
            var acc_data: [[Double]] = []
            
            for row in csvFile.rows {
                let rowData: [Double] = [Double(row["time"]!)!, Double(row["x"]!)!, Double(row["y"]!)!, Double(row["z"]!)!]
                acc_data.append(rowData)
            }
            
            // Perform calculations for each 10-second window
            var full_frame: [[Double]] = []
            var i = 0
            var prev_ts = 0
            var sub_frame: [[Double]] = []
            let tot_rows =  acc_data.count
            
            // loop from 0 to tot_rows
            for idx in 0..<tot_rows {
                if idx%1000 == 0 {
                    //FIXME remove this, will make the console messy
                    print(" \(idx) **")
                }
                
                let curr_row = acc_data[idx]
                let curr_ts = Int(curr_row[0].truncatingRemainder(dividingBy: 1000))
                
                if idx != 0{
                    //FIXME assuming the 0th column is the timestamp
                    prev_ts = Int(acc_data[idx-1][0].truncatingRemainder(dividingBy: 1000))
                }
                
                if curr_ts > prev_ts {
                    sub_frame.append(curr_row)
                } else {
                    var metrics_axis: [Double] = []
                    
                    // add last timestamp (last row, first column)
                    metrics_axis.append(sub_frame[sub_frame.count - 1][0])
                    
                    // iterate over col from 1 to 4
                    for col in 1..<4 {
                        // if statements for each metric number in Features
                        let columnValues = sub_frame.map { $0[col] }
                        
                        if metric_no == Features.Mean.rawValue{
                            metrics_axis.append(calculateMean(values: columnValues)!)
                        } else if metric_no == Features.Median.rawValue{
                            metrics_axis.append(calculateMedian(values: columnValues)!)
                        } else if metric_no == Features.Std_Dev.rawValue{
                            metrics_axis.append(calculateStandardDeviation(values: columnValues)!)
                        } else if metric_no == Features.Max_Raw.rawValue{
                            metrics_axis.append(calculateMaximum(values: columnValues)!)
                        } else if metric_no == Features.Min_Raw.rawValue{
                            metrics_axis.append(calculateMinimum(values: columnValues)!)
                            
                        } else if metric_no == Features.Max_Abs.rawValue{
                            //get the absolute value of each element in the column
                            let abs_columnValues = columnValues.map { abs($0) }
                            metrics_axis.append(calculateMaximum(values: abs_columnValues)!)
                        } else if metric_no == Features.Min_Abs.rawValue{
                            //get the absolute value of each element in the column
                            let abs_columnValues = columnValues.map { abs($0) }
                            metrics_axis.append(calculateMinimum(values: abs_columnValues)!)
                        }
                    }
                    full_frame.append(metrics_axis)
                    sub_frame = []
                }
            }
            
            var outputFileName = "\(FeatureType[Features(rawValue: metric_no)!]!)_all_per_sec_all_axis.csv"
            
            guard let outputFileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(outputFileName) else {
                print("Failed to create file URL")
                return ""
            }
            
            do {
                let stream = OutputStream(toFileAtPath: outputFileURL.path, append: false)!
                let csv = try! CSVWriter(stream: stream)
                let headers: [String] = ["time", "x", "y", "z"] // Add or modify headers based on your specific metrics and calculations
                try csv.write(row: headers)
                //write all rows of full_frame to csv
                for row in full_frame {
                    //convert row to string that can be written to csv
                    let stringRow = row.map { String(describing: $0) }
                    try csv.write(row: stringRow)
                }
            } catch {
                print("Error writing CSV: \(error.localizedDescription)")
                return ""
            }
            
            print("create_per_second SUCCESS: \(metric_no)")
            return outputFileURL.path
        } catch {
            // Handle the error
            print("Error: \(error.localizedDescription)")
            return ""
        }
    }

    func create_per_window_data(file: String, metric_no: Int) -> String{
        // Read the CSV file using SwiftCSV
        do {
            let csvFile = try SwiftCSV.CSV<Named>(url: URL(fileURLWithPath: file))
            var outputFileName = ""
            
            // Extract data from the CSV file
            var mean_all: [[Double]] = []
            
            for row in csvFile.rows {
                let rowData: [Double] = [Double(row["time"]!)!, Double(row["x"]!)!, Double(row["y"]!)!, Double(row["z"]!)!]
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
                    let sub_frameSlice = mean_all[i..<i+10]
                    let sub_frame = sub_frameSlice.map { $0[col] }
                    // append mean of sub_frame
                    single_row.append(calculateMean(values: sub_frame)!)
                    
                    // append variance of sub_frame
                    single_row.append(calculateVariance(values: sub_frame)!)
                    
                    // append max of sub_frame
                    single_row.append(calculateMaximum(values: sub_frame)!)
                    
                    // append min of sub_frame
                    single_row.append(calculateMinimum(values: sub_frame)!)
                    
                    // sort sub_frame from low to high
                    let sorted_sub_frame = sub_frame.sorted()
                    
                    // append mean of lower half of sub_frame
                    let lowerQuarterStartIndex = 0
                    let lowerQuarterEndIndex = sorted_sub_frame.count / 4
                    
                    let upperQuarterStartIndex = 3 * sorted_sub_frame.count / 4
                    let upperQuarterEndIndex = sorted_sub_frame.count
                    
                    single_row.append(calculateMean(values: Array(sorted_sub_frame[lowerQuarterStartIndex..<lowerQuarterEndIndex]))!)
                    //append mean of upper half of sub_frame from 8 to 10
                    single_row.append(calculateMean(values: Array(sorted_sub_frame[upperQuarterStartIndex..<upperQuarterEndIndex]))!)
                }
                
                full_frame.append(single_row)
                single_row = []
                i += 10
            }
            
            let col_names = ["xMe", "xVr", "xMx", "xMi", "xUM", "xLM", "yMe", "yVr", "yMx", "yMn", "yUM", "yLM", "zMe", "zVr", "zMx", "zMi", "zUM", "zLM"]
        
            //not doing df1 creation efficiently
            var df1=DataFrame()
            let tColumn = Column(name:"t", contents: full_frame.map{$0[0]})
            let xMeColumn = Column(name: "\(metric_no)xMe", contents: full_frame.map{$0[1]})
            let xVrColumn = Column(name: "\(metric_no)xVr", contents: full_frame.map{$0[2]})
            let xMxColumn = Column(name: "\(metric_no)xMx", contents: full_frame.map{$0[3]})
            let xMiColumn = Column(name: "\(metric_no)xMi", contents: full_frame.map{$0[4]})
            let xUMColumn = Column(name: "\(metric_no)xUM", contents: full_frame.map{$0[5]})
            let xLMColumn = Column(name: "\(metric_no)xLM", contents: full_frame.map{$0[6]})
            let yMeColumn = Column(name: "\(metric_no)yMe", contents: full_frame.map{$0[7]})
            let yVrColumn = Column(name: "\(metric_no)yVr", contents: full_frame.map{$0[8]})
            let yMxColumn = Column(name: "\(metric_no)yMx", contents: full_frame.map{$0[9]})
            let yMnColumn = Column(name: "\(metric_no)yMn", contents: full_frame.map{$0[10]})
            let yUMColumn = Column(name: "\(metric_no)yUM", contents: full_frame.map{$0[11]})
            let yLMColumn = Column(name: "\(metric_no)yLM", contents: full_frame.map{$0[12]})
            let zMeColumn = Column(name: "\(metric_no)zMe", contents: full_frame.map{$0[13]})
            let zVrColumn = Column(name: "\(metric_no)zVr", contents: full_frame.map{$0[14]})
            let zMxColumn = Column(name: "\(metric_no)zMx", contents: full_frame.map{$0[15]})
            let zMiColumn = Column(name: "\(metric_no)zMi", contents: full_frame.map{$0[16]})
            let zUMColumn = Column(name: "\(metric_no)zUM", contents: full_frame.map{$0[17]})
            let zLMColumn = Column(name: "\(metric_no)zLM", contents: full_frame.map{$0[18]})
            
            df1.append(column: tColumn)
            df1.append(column: xMeColumn)
            df1.append(column: xVrColumn)
            df1.append(column: xMxColumn)
            df1.append(column: xMiColumn)
            df1.append(column: xUMColumn)
            df1.append(column: xLMColumn)
            df1.append(column: yMeColumn)
            df1.append(column: yVrColumn)
            df1.append(column: yMxColumn)
            df1.append(column: yMnColumn)
            df1.append(column: yUMColumn)
            df1.append(column: yLMColumn)
            df1.append(column: zMeColumn)
            df1.append(column: zVrColumn)
            df1.append(column: zMxColumn)
            df1.append(column: zMiColumn)
            df1.append(column: zUMColumn)
            df1.append(column: zLMColumn)
            
            if metric_no <= 14 {
                var diff_frame: [[Double]] = []
                
                // declare a row variable
                var diff_row: [Double] = []
                var curr_row: [Double] = []
                var prev_row: [Double] = []
                
                for i in 0...full_frame.count-1{
                    if i == 0 {
                        // append to full frame the first row of full frame without the first column
                        // make diff_row equal to the first row of full frame without the first column
                        diff_row = Array(full_frame[i].dropFirst())
                        diff_frame.append(diff_row)
                        
                    } else {
                        // append to full frame the difference between the current row and the previous row
                        curr_row = Array(full_frame[i][1...])
                        prev_row = Array(full_frame[i-1][1...])
                        diff_row = zip(curr_row, prev_row).map{$0.0 - $0.1}
                        diff_frame.append(diff_row)
                    }
                }
                
                let dxMeColumn = Column(name: "\(metric_no)dxMe", contents: diff_frame.map{$0[0]})
                let dxVrColumn = Column(name: "\(metric_no)dxVr", contents: diff_frame.map{$0[1]})
                let dxMxColumn = Column(name: "\(metric_no)dxMx", contents: diff_frame.map{$0[2]})
                let dxMiColumn = Column(name: "\(metric_no)dxMi", contents: diff_frame.map{$0[3]})
                let dxUMColumn = Column(name: "\(metric_no)dxUM", contents: diff_frame.map{$0[4]})
                let dxLMColumn = Column(name: "\(metric_no)dxLM", contents: diff_frame.map{$0[5]})
                let dyMeColumn = Column(name: "\(metric_no)dyMe", contents: diff_frame.map{$0[6]})
                let dyVrColumn = Column(name: "\(metric_no)dyVr", contents: diff_frame.map{$0[7]})
                let dyMxColumn = Column(name: "\(metric_no)dyMx", contents: diff_frame.map{$0[8]})
                let dyMnColumn = Column(name: "\(metric_no)dyMn", contents: diff_frame.map{$0[9]})
                let dyUMColumn = Column(name: "\(metric_no)dyUM", contents: diff_frame.map{$0[10]})
                let dyLMColumn = Column(name: "\(metric_no)dyLM", contents: diff_frame.map{$0[11]})
                let dzMeColumn = Column(name: "\(metric_no)dzMe", contents: diff_frame.map{$0[12]})
                let dzVrColumn = Column(name: "\(metric_no)dzVr", contents: diff_frame.map{$0[13]})
                let dzMxColumn = Column(name: "\(metric_no)dzMx", contents: diff_frame.map{$0[14]})
                let dzMiColumn = Column(name: "\(metric_no)dzMi", contents: diff_frame.map{$0[15]})
                let dzUMColumn = Column(name: "\(metric_no)dzUM", contents: diff_frame.map{$0[16]})
                let dzLMColumn = Column(name: "\(metric_no)dzLM", contents: diff_frame.map{$0[17]})
                
                df1.append(column: dxMeColumn)
                df1.append(column: dxVrColumn)
                df1.append(column: dxMxColumn)
                df1.append(column: dxMiColumn)
                df1.append(column: dxUMColumn)
                df1.append(column: dxLMColumn)
                df1.append(column: dyMeColumn)
                df1.append(column: dyVrColumn)
                df1.append(column: dyMxColumn)
                df1.append(column: dyMnColumn)
                df1.append(column: dyUMColumn)
                df1.append(column: dyLMColumn)
                df1.append(column: dzMeColumn)
                df1.append(column: dzVrColumn)
                df1.append(column: dzMxColumn)
                df1.append(column: dzMiColumn)
                df1.append(column: dzUMColumn)
                df1.append(column: dzLMColumn)
     
                outputFileName = "Metric_\(metric_no)_36.csv"
            } else {
                outputFileName = "Metric_\(metric_no)_18.csv"
            }
            
            guard let outputFileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(outputFileName) else {
                print("Failed to create file URL")
                return ""
            }
            
            do {
                try df1.writeCSV(to: URL(fileURLWithPath: outputFileURL.path))
                
            } catch {
                print("Error: \(error.localizedDescription)")
                return ""
            }
            //may need to return full path (outputURL.path)
            print("create_per_window SUCCESS \(metric_no)")
            //                print(outputFileURL.path)
            return outputFileURL.deletingLastPathComponent().path
        }
        catch {
            print("Error: \(error.localizedDescription)")
            return ""
        }
    }
    
    func processData(datafile: String) -> String {
        print("processing data!")
        
        var perWindowDataDir: String = ""
        for metricNum in Features.allCases{
            let perSecondDataFile = create_per_second_data(file: datafile, metric_no: metricNum.rawValue)
            perWindowDataDir = create_per_window_data(file: perSecondDataFile, metric_no: metricNum.rawValue)
        }
        
        print("SUCCESS creating all window data")
        
        print("Window data in: \(perWindowDataDir)")
        
        let result = combine_features(csvPath: perWindowDataDir)!
        print("combining features success")
        
        return result
    }
}
