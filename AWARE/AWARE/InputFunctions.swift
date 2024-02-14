//
//  InputFunctions.swift
//  AWARE
//
//  Created by Gita Supramaniam on 2/10/24.
//

import Foundation


class InputFunctions{
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

    func create_per_second_data(file: String, metric_no: Int) -> String{
        //FIXME implement create_per_second_data to write to processed second data to file and return file URL
        return ""
    }
    func create_per_window_data(file: String, metric_no: Int) -> String{
        //FIXME implement create_per_window_data to write to processed window data file and return file URL
        return ""
    }
    
    func processData(windowFile: String) -> String {
        for metricNum in Features.allCases{
            let perSecondDataFile = create_per_second_data(file: windowFile, metric_no: metricNum.rawValue)
            let perWindowDataFile = create_per_window_data(file: perSecondDataFile, metric_no: metricNum.rawValue)
        }
        return ""
    }

}
