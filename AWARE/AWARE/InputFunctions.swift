//
//  InputFunctions.swift
//  AWARE
//
//  Created by Gita Supramaniam on 2/10/24.
//

import Foundation


class InputFunctions{
    enum Features: Int {
        case Mean = 0
        case Median = 1
        case Std_Dev = 2
        case ZeroCrsRate = 3
        case Max_Raw = 4
        case Min_Raw = 5
        case Max_Abs = 6
        case Min_Abs = 7
        case Spec_Ent_Time = 8
        case Skewness = 9
        case Kurtosis = 10
    }
    var featureType: [Features: String] = [

        .Mean : "Mean",
        .Median : "Median",
        .Std_Dev : "Std_Dev",
        .ZeroCrsRate : "ZeroCrsRate",
        .Max_Raw  : "Max_Raw",
        .Min_Raw : "Min_Raw",
        .Max_Abs : "Max_Abs",
            .Min_Abs : "Min_Abs",
        .Spec_Ent_Time : "Spec_Ent_Time",
        .Skewness : "Skewness",
        .Kurtosis : "Kurtosis"
    ]
}
