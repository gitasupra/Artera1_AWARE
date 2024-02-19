//
//  InputFunctions.swift
//  AWARE
//
//  Created by Gita Supramaniam on 2/10/24.
//

import Foundation
import SwiftCSV
import TabularData


class InputFunctions : ObservableObject{
    enum Features: Int, CaseIterable {
        case Mean = 0
        case Median = 1
        case Std_Dev = 2
        case Max_Raw = 3
        case Min_Raw = 4
        case Max_Abs = 5
        case Min_Abs = 6
    }
    var featureType: [Features: String] = [
        
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
    
    // helper function to calculate minimum and maximum values
    func calculateMinimum(values: [Double]) -> Double? {
        guard let minValue = values.min() else {
            return nil // Return nil for an empty array
        }
        return minValue
    }
    
    func calculateMaximum(values: [Double]) -> Double? {
        guard let maxValue = values.max() else {
            return nil // Return nil for an empty array
        }
        return maxValue
    }
    
    
    func calculateVariance(values: [Double]) -> Double? {
        guard let mean = calculateMean(values: values) else {
            return nil // Return nil if mean calculation fails
        }
        let squaredDifferences = values.map { pow($0 - mean, 2) }
        let sumOfSquaredDifferences = squaredDifferences.reduce(0, +)
        let variance = sumOfSquaredDifferences / Double(values.count)
        return variance
    }
    
    func create_per_second_data(file: String, metric_no: Int) -> String {
       
        // Read the CSV file using SwiftCSV
        do {
            let csvFile = try CSV<Named>(url: URL(fileURLWithPath: file))
            var outputFileName = ""

            // Extract data from the CSV file
            var acc_data: [[Double]] = []

            for row in csvFile.rows {
                let rowData: [Double] = [Double(row["time"]!)!, Double(row["x"]!)!, Double(row["y"]!)!, Double(row["z"]!)!]
                mean_all.append(rowData)
            }

            // Perform calculations for each 10-second window
            var full_frame: [[Double]] = []
            var metrics_axis: [Double] = []
            var i = 0
            
            var prev_ts = 0
            var sub_frame: [[Double]] = []
            var full_frame: [[Double]] = []
            let tot_rows =  acc_data.count

            while i + 10 < tot_rows {
                metrics_axis.append(mean_all[i + 9][0])

                for col in 1...3 {
                    let sub_frame = mean_all[i..<i + 10][col]
                    
                    // Append mean of sub_frame
                    if let meanValue = calculateMean(values: sub_frame) {
                        metrics_axis.append(meanValue)
                    } else {
                        // Handle the case where calculation fails
                        continue
                    }

                    // Append variance of sub_frame
                    if let varianceValue = calculateVariance(values: sub_frame) {
                        metrics_axis.append(varianceValue)
                    } else {
                        // Handle the case where calculation fails
                        continue
                    }

                    // Append max of sub_frame
                    if let maxValue = calculateMaximum(values: sub_frame) {
                        metrics_axis.append(maxValue)
                    } else {
                        // Handle the case where calculation fails
                        continue
                    }

                    // Append min of sub_frame
                    if let minValue = calculateMinimum(values: sub_frame) {
                        metrics_axis.append(minValue)
                    } else {
                        // Handle the case where calculation fails
                        continue
                    }
                }

                full_frame.append(metrics_axis)
                sub_frame = []
                i += 10
            }
            full_frame += full_frame  //     full_frame = np.array(full_frame)


            // Create a DataFrame
            var df1 = DataFrame()
//            
      

            // Write the DataFrame to a CSV file
            do {
                outputFileName = "\(metric_no)_per_second_data.csv"
                try df1.writeCSV(to: URL(fileURLWithPath: outputFileName))
            } catch {
                print("Error writing CSV: \(error.localizedDescription)")
                return ""
            }

            return outputFileName
        } catch {
            // Handle the error
            print("Error: \(error.localizedDescription)")
            return ""
        }
    }



    
   
        func create_per_window_data(file: String, metric_no: Int) -> String{
            //TODO: test on input file
            
            // Read the CSV file using SwiftCSV
            do{
                
                let csvFile = try CSV<Named>(url: URL(fileURLWithPath: file))
                var outputFileName = ""
                
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
                
                
                while i + 10 < tot_rows{
                    single_row.append(mean_all[i+9][0])
                    for col in 1...3{
                        let sub_frame = mean_all[i..<i+10][col]
                        //append mean of sub_frame
                        single_row.append(calculateMean(values: sub_frame)!)
                        
                        //append variance of sub_frame
                        single_row.append(calculateVariance(values: sub_frame)!)
                        
                        //append max of sub_frame
                        single_row.append(calculateMaximum(values: sub_frame)!)
                        
                        //append min of sub_frame
                        single_row.append(calculateMinimum(values: sub_frame)!)
                        
                        //sort sub_frame from low to high
                        let sorted_sub_frame = sub_frame.sorted()
                        //append mean of lower half of sub_frame
                        single_row.append(calculateMean(values: Array(sorted_sub_frame[0..<4]))!)
                        //append mean of upper half of sub_frame from 8 to 10
                        single_row.append(calculateMean(values: Array(sorted_sub_frame[8..<10]))!)
                    }
                    
                    full_frame.append(single_row)
                    single_row = []
                    i += 10
                }
                
                let col_names = ["xMe", "xVr", "xMx", "xMi", "xUM", "xLM", "yMe", "yVr", "yMx", "yMn", "yUM", "yLM", "zMe", "zVr", "zMx", "zMi", "zUM", "zLM"]
                
                
                // let columnNames = ["t"] + col_names.map{"\(metric_no)\($0)"}
                
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
                
                if metric_no <= 14{
                    var diff_frame: [[Double]] = []
                    //declare a row variable
                    var diff_row: [Double] = []
                    var curr_row: [Double] = []
                    var prev_row: [Double] = []
                    
                    for i in 1...full_frame.count{
                        if i==0{
                            //append to full frame the first row of full frame without the first column
                            //make diff_row equal to the first row of full frame without the first column
                            diff_row = Array(full_frame[i].dropFirst())
                            diff_frame.append(diff_row)
                            
                        }
                        else{
                            //append to full frame the difference between the current row and the previous row
                            
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
                    
                    
                }
                else{
                    outputFileName = "Metric_\(metric_no)_18.csv"
                }
                
                
                
                //write the dataframe to a csv file, atomically = should overwrite the file if it already exists
                
                do{
                    
                    try df1.writeCSV(to: URL(fileURLWithPath: outputFileName))
                    
                }
                catch{
                    print("Error: \(error.localizedDescription)")
                }
                
                
                //may need to return full path (outputURL.path)
                return outputFileName
                
                
            }
            catch{
                print("Error: \(error.localizedDescription)")
                return ""
            }
            return ""
        }
        
        func processData(windowFile: String) -> String {
            print("processing data!")
            //FIXME: temporarily changing create_per_second to have test file name
            var testfile: String = ""
            do{
                testfile = Bundle.main.path(forResource: "BK7610", ofType: "csv")!
            }
            catch{
                print("Error: \(error.localizedDescription)")
                print("could not get file")
            }
            for metricNum in Features.allCases{
                let perSecondDataFile = create_per_second_data(file: testfile, metric_no: metricNum.rawValue)
                let perWindowDataFile = create_per_window_data(file: perSecondDataFile, metric_no: metricNum.rawValue)
            }
            return ""
        }
        
    }

