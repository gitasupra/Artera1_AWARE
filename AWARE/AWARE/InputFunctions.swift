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
