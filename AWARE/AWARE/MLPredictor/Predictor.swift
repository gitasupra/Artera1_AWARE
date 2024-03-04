//
//  Predictor.swift
//  AWARE
//
//  Created by Jessica Nguyen on 3/2/24.
//

import CoreML
import SwiftCSV

class Predictor {
    static func predictLevel(file: String) -> Int{
        do {
            let config = MLModelConfiguration()
            let model = try! alcohol(configuration: config)
            
            // Read the processed CSV file using SwiftCSV
            let csvFile = try! CSV<Named>(url: URL(fileURLWithPath: file))
            
            var featureDictionary = [String: Double]()
            
            for row in csvFile.rows {
                if let xMeValue0 = row["0xMe"].flatMap(Double.init) { featureDictionary["0xMe"] = xMeValue0 }
                if let xVrValue0 = row["0xVr"].flatMap(Double.init) { featureDictionary["0xVr"] = xVrValue0 }
                if let xMxValue0 = row["0xMx"].flatMap(Double.init) { featureDictionary["0xMx"] = xMxValue0 }
                if let xMiValue0 = row["0xMi"].flatMap(Double.init) { featureDictionary["0xMi"] = xMiValue0 }
                if let xUMValue0 = row["0xUM"].flatMap(Double.init) { featureDictionary["0xUM"] = xUMValue0 }
                if let xLMValue0 = row["0xLM"].flatMap(Double.init) { featureDictionary["0xLM"] = xLMValue0 }
                if let yMeValue0 = row["0yMe"].flatMap(Double.init) { featureDictionary["0yMe"] = yMeValue0 }
                if let yVrValue0 = row["0yVr"].flatMap(Double.init) { featureDictionary["0yVr"] = yVrValue0 }
                if let yMxValue0 = row["0yMx"].flatMap(Double.init) { featureDictionary["0yMx"] = yMxValue0 }
                if let yMnValue0 = row["0yMn"].flatMap(Double.init) { featureDictionary["0yMn"] = yMnValue0 }
                if let yUMValue0 = row["0yUM"].flatMap(Double.init) { featureDictionary["0yUM"] = yUMValue0 }
                if let yLMValue0 = row["0yLM"].flatMap(Double.init) { featureDictionary["0yLM"] = yLMValue0 }
                if let zMeValue0 = row["0zMe"].flatMap(Double.init) { featureDictionary["0zMe"] = zMeValue0 }
                if let zVrValue0 = row["0zVr"].flatMap(Double.init) { featureDictionary["0zVr"] = zVrValue0 }
                if let zMxValue0 = row["0zMx"].flatMap(Double.init) { featureDictionary["0zMx"] = zMxValue0 }
                if let zMiValue0 = row["0zMi"].flatMap(Double.init) { featureDictionary["0zMi"] = zMiValue0 }
                if let zUMValue0 = row["0zUM"].flatMap(Double.init) { featureDictionary["0zUM"] = zUMValue0 }
                if let zLMValue0 = row["0zLM"].flatMap(Double.init) { featureDictionary["0zLM"] = zLMValue0 }
                
                if let dxMeValue0 = row["0dxMe"].flatMap(Double.init) { featureDictionary["0dxMe"] = dxMeValue0 }
                if let dxVrValue0 = row["0dxVr"].flatMap(Double.init) { featureDictionary["0dxVr"] = dxVrValue0 }
                if let dxMxValue0 = row["0dxMx"].flatMap(Double.init) { featureDictionary["0dxMx"] = dxMxValue0 }
                if let dxMiValue0 = row["0dxMi"].flatMap(Double.init) { featureDictionary["0dxMi"] = dxMiValue0 }
                if let dxUMValue0 = row["0dxUM"].flatMap(Double.init) { featureDictionary["0dxUM"] = dxUMValue0 }
                if let dxLMValue0 = row["0dxLM"].flatMap(Double.init) { featureDictionary["0dxLM"] = dxLMValue0 }
                if let dyMeValue0 = row["0dyMe"].flatMap(Double.init) { featureDictionary["0dyMe"] = dyMeValue0 }
                if let dyVrValue0 = row["0dyVr"].flatMap(Double.init) { featureDictionary["0dyVr"] = dyVrValue0 }
                if let dyMxValue0 = row["0dyMx"].flatMap(Double.init) { featureDictionary["0dyMx"] = dyMxValue0 }
                if let dyMnValue0 = row["0dyMn"].flatMap(Double.init) { featureDictionary["0dyMn"] = dyMnValue0 }
                if let dyUMValue0 = row["0dyUM"].flatMap(Double.init) { featureDictionary["0dyUM"] = dyUMValue0 }
                if let dyLMValue0 = row["0dyLM"].flatMap(Double.init) { featureDictionary["0dyLM"] = dyLMValue0 }
                if let dzMeValue0 = row["0dzMe"].flatMap(Double.init) { featureDictionary["0dzMe"] = dzMeValue0 }
                if let dzVrValue0 = row["0dzVr"].flatMap(Double.init) { featureDictionary["0dzVr"] = dzVrValue0 }
                if let dzMxValue0 = row["0dzMx"].flatMap(Double.init) { featureDictionary["0dzMx"] = dzMxValue0 }
                if let dzMiValue0 = row["0dzMi"].flatMap(Double.init) { featureDictionary["0dzMi"] = dzMiValue0 }
                if let dzUMValue0 = row["0dzUM"].flatMap(Double.init) { featureDictionary["0dzUM"] = dzUMValue0 }
                if let dzLMValue0 = row["0dzLM"].flatMap(Double.init) { featureDictionary["0dzLM"] = dzLMValue0 }
                
                if let xMeValue1 = row["1xMe"].flatMap(Double.init) { featureDictionary["1xMe"] = xMeValue1 }
                if let xVrValue1 = row["1xVr"].flatMap(Double.init) { featureDictionary["1xVr"] = xVrValue1 }
                if let xMxValue1 = row["1xMx"].flatMap(Double.init) { featureDictionary["1xMx"] = xMxValue1 }
                if let xMiValue1 = row["1xMi"].flatMap(Double.init) { featureDictionary["1xMi"] = xMiValue1 }
                if let xUMValue1 = row["1xUM"].flatMap(Double.init) { featureDictionary["1xUM"] = xUMValue1 }
                if let xLMValue1 = row["1xLM"].flatMap(Double.init) { featureDictionary["1xLM"] = xLMValue1 }
                if let yMeValue1 = row["1yMe"].flatMap(Double.init) { featureDictionary["1yMe"] = yMeValue1 }
                if let yVrValue1 = row["1yVr"].flatMap(Double.init) { featureDictionary["1yVr"] = yVrValue1 }
                if let yMxValue1 = row["1yMx"].flatMap(Double.init) { featureDictionary["1yMx"] = yMxValue1 }
                if let yMnValue1 = row["1yMn"].flatMap(Double.init) { featureDictionary["1yMn"] = yMnValue1 }
                if let yUMValue1 = row["1yUM"].flatMap(Double.init) { featureDictionary["1yUM"] = yUMValue1 }
                if let yLMValue1 = row["1yLM"].flatMap(Double.init) { featureDictionary["1yLM"] = yLMValue1 }
                if let zMeValue1 = row["1zMe"].flatMap(Double.init) { featureDictionary["1zMe"] = zMeValue1 }
                if let zVrValue1 = row["1zVr"].flatMap(Double.init) { featureDictionary["1zVr"] = zVrValue1 }
                if let zMxValue1 = row["1zMx"].flatMap(Double.init) { featureDictionary["1zMx"] = zMxValue1 }
                if let zMiValue1 = row["1zMi"].flatMap(Double.init) { featureDictionary["1zMi"] = zMiValue1 }
                if let zUMValue1 = row["1zUM"].flatMap(Double.init) { featureDictionary["1zUM"] = zUMValue1 }
                if let zLMValue1 = row["1zLM"].flatMap(Double.init) { featureDictionary["1zLM"] = zLMValue1 }
                
                if let dxMeValue1 = row["1dxMe"].flatMap(Double.init) { featureDictionary["1dxMe"] = dxMeValue1 }
                if let dxVrValue1 = row["1dxVr"].flatMap(Double.init) { featureDictionary["1dxVr"] = dxVrValue1 }
                if let dxMxValue1 = row["1dxMx"].flatMap(Double.init) { featureDictionary["1dxMx"] = dxMxValue1 }
                if let dxMiValue1 = row["1dxMi"].flatMap(Double.init) { featureDictionary["1dxMi"] = dxMiValue1 }
                if let dxUMValue1 = row["1dxUM"].flatMap(Double.init) { featureDictionary["1dxUM"] = dxUMValue1 }
                if let dxLMValue1 = row["1dxLM"].flatMap(Double.init) { featureDictionary["1dxLM"] = dxLMValue1 }
                if let dyMeValue1 = row["1dyMe"].flatMap(Double.init) { featureDictionary["1dyMe"] = dyMeValue1 }
                if let dyVrValue1 = row["1dyVr"].flatMap(Double.init) { featureDictionary["1dyVr"] = dyVrValue1 }
                if let dyMxValue1 = row["1dyMx"].flatMap(Double.init) { featureDictionary["1dyMx"] = dyMxValue1 }
                if let dyMnValue1 = row["1dyMn"].flatMap(Double.init) { featureDictionary["1dyMn"] = dyMnValue1 }
                if let dyUMValue1 = row["1dyUM"].flatMap(Double.init) { featureDictionary["1dyUM"] = dyUMValue1 }
                if let dyLMValue1 = row["1dyLM"].flatMap(Double.init) { featureDictionary["1dyLM"] = dyLMValue1 }
                if let dzMeValue1 = row["1dzMe"].flatMap(Double.init) { featureDictionary["1dzMe"] = dzMeValue1 }
                if let dzVrValue1 = row["1dzVr"].flatMap(Double.init) { featureDictionary["1dzVr"] = dzVrValue1 }
                if let dzMxValue1 = row["1dzMx"].flatMap(Double.init) { featureDictionary["1dzMx"] = dzMxValue1 }
                if let dzMiValue1 = row["1dzMi"].flatMap(Double.init) { featureDictionary["1dzMi"] = dzMiValue1 }
                if let dzUMValue1 = row["1dzUM"].flatMap(Double.init) { featureDictionary["1dzUM"] = dzUMValue1 }
                if let dzLMValue1 = row["1dzLM"].flatMap(Double.init) { featureDictionary["1dzLM"] = dzLMValue1 }
                
                if let xMeValue2 = row["2xMe"].flatMap(Double.init) { featureDictionary["2xMe"] = xMeValue2 }
                if let xVrValue2 = row["2xVr"].flatMap(Double.init) { featureDictionary["2xVr"] = xVrValue2 }
                if let xMxValue2 = row["2xMx"].flatMap(Double.init) { featureDictionary["2xMx"] = xMxValue2 }
                if let xMiValue2 = row["2xMi"].flatMap(Double.init) { featureDictionary["2xMi"] = xMiValue2 }
                if let xUMValue2 = row["2xUM"].flatMap(Double.init) { featureDictionary["2xUM"] = xUMValue2 }
                if let xLMValue2 = row["2xLM"].flatMap(Double.init) { featureDictionary["2xLM"] = xLMValue2 }
                if let yMeValue2 = row["2yMe"].flatMap(Double.init) { featureDictionary["2yMe"] = yMeValue2 }
                if let yVrValue2 = row["2yVr"].flatMap(Double.init) { featureDictionary["2yVr"] = yVrValue2 }
                if let yMxValue2 = row["2yMx"].flatMap(Double.init) { featureDictionary["2yMx"] = yMxValue2 }
                if let yMnValue2 = row["2yMn"].flatMap(Double.init) { featureDictionary["2yMn"] = yMnValue2 }
                if let yUMValue2 = row["2yUM"].flatMap(Double.init) { featureDictionary["2yUM"] = yUMValue2 }
                if let yLMValue2 = row["2yLM"].flatMap(Double.init) { featureDictionary["2yLM"] = yLMValue2 }
                if let zMeValue2 = row["2zMe"].flatMap(Double.init) { featureDictionary["2zMe"] = zMeValue2 }
                if let zVrValue2 = row["2zVr"].flatMap(Double.init) { featureDictionary["2zVr"] = zVrValue2 }
                if let zMxValue2 = row["2zMx"].flatMap(Double.init) { featureDictionary["2zMx"] = zMxValue2 }
                if let zMiValue2 = row["2zMi"].flatMap(Double.init) { featureDictionary["2zMi"] = zMiValue2 }
                if let zUMValue2 = row["2zUM"].flatMap(Double.init) { featureDictionary["2zUM"] = zUMValue2 }
                if let zLMValue2 = row["2zLM"].flatMap(Double.init) { featureDictionary["2zLM"] = zLMValue2 }
                
                if let dxMeValue2 = row["2dxMe"].flatMap(Double.init) { featureDictionary["2dxMe"] = dxMeValue2 }
                if let dxVrValue2 = row["2dxVr"].flatMap(Double.init) { featureDictionary["2dxVr"] = dxVrValue2 }
                if let dxMxValue2 = row["2dxMx"].flatMap(Double.init) { featureDictionary["2dxMx"] = dxMxValue2 }
                if let dxMiValue2 = row["2dxMi"].flatMap(Double.init) { featureDictionary["2dxMi"] = dxMiValue2 }
                if let dxUMValue2 = row["2dxUM"].flatMap(Double.init) { featureDictionary["2dxUM"] = dxUMValue2 }
                if let dxLMValue2 = row["2dxLM"].flatMap(Double.init) { featureDictionary["2dxLM"] = dxLMValue2 }
                if let dyMeValue2 = row["2dyMe"].flatMap(Double.init) { featureDictionary["2dyMe"] = dyMeValue2 }
                if let dyVrValue2 = row["2dyVr"].flatMap(Double.init) { featureDictionary["2dyVr"] = dyVrValue2 }
                if let dyMxValue2 = row["2dyMx"].flatMap(Double.init) { featureDictionary["2dyMx"] = dyMxValue2 }
                if let dyMnValue2 = row["2dyMn"].flatMap(Double.init) { featureDictionary["2dyMn"] = dyMnValue2 }
                if let dyUMValue2 = row["2dyUM"].flatMap(Double.init) { featureDictionary["2dyUM"] = dyUMValue2 }
                if let dyLMValue2 = row["2dyLM"].flatMap(Double.init) { featureDictionary["2dyLM"] = dyLMValue2 }
                if let dzMeValue2 = row["2dzMe"].flatMap(Double.init) { featureDictionary["2dzMe"] = dzMeValue2 }
                if let dzVrValue2 = row["2dzVr"].flatMap(Double.init) { featureDictionary["2dzVr"] = dzVrValue2 }
                if let dzMxValue2 = row["2dzMx"].flatMap(Double.init) { featureDictionary["2dzMx"] = dzMxValue2 }
                if let dzMiValue2 = row["2dzMi"].flatMap(Double.init) { featureDictionary["2dzMi"] = dzMiValue2 }
                if let dzUMValue2 = row["2dzUM"].flatMap(Double.init) { featureDictionary["2dzUM"] = dzUMValue2 }
                if let dzLMValue2 = row["2dzLM"].flatMap(Double.init) { featureDictionary["2dzLM"] = dzLMValue2 }
                
                if let xMeValue4 = row["4xMe"].flatMap(Double.init) { featureDictionary["4xMe"] = xMeValue4 }
                if let xVrValue4 = row["4xVr"].flatMap(Double.init) { featureDictionary["4xVr"] = xVrValue4 }
                if let xMxValue4 = row["4xMx"].flatMap(Double.init) { featureDictionary["4xMx"] = xMxValue4 }
                if let xMiValue4 = row["4xMi"].flatMap(Double.init) { featureDictionary["4xMi"] = xMiValue4 }
                if let xUMValue4 = row["4xUM"].flatMap(Double.init) { featureDictionary["4xUM"] = xUMValue4 }
                if let xLMValue4 = row["4xLM"].flatMap(Double.init) { featureDictionary["4xLM"] = xLMValue4 }
                if let yMeValue4 = row["4yMe"].flatMap(Double.init) { featureDictionary["4yMe"] = yMeValue4 }
                if let yVrValue4 = row["4yVr"].flatMap(Double.init) { featureDictionary["4yVr"] = yVrValue4 }
                if let yMxValue4 = row["4yMx"].flatMap(Double.init) { featureDictionary["4yMx"] = yMxValue4 }
                if let yMnValue4 = row["4yMn"].flatMap(Double.init) { featureDictionary["4yMn"] = yMnValue4 }
                if let yUMValue4 = row["4yUM"].flatMap(Double.init) { featureDictionary["4yUM"] = yUMValue4 }
                if let yLMValue4 = row["4yLM"].flatMap(Double.init) { featureDictionary["4yLM"] = yLMValue4 }
                if let zMeValue4 = row["4zMe"].flatMap(Double.init) { featureDictionary["4zMe"] = zMeValue4 }
                if let zVrValue4 = row["4zVr"].flatMap(Double.init) { featureDictionary["4zVr"] = zVrValue4 }
                if let zMxValue4 = row["4zMx"].flatMap(Double.init) { featureDictionary["4zMx"] = zMxValue4 }
                if let zMiValue4 = row["4zMi"].flatMap(Double.init) { featureDictionary["4zMi"] = zMiValue4 }
                if let zUMValue4 = row["4zUM"].flatMap(Double.init) { featureDictionary["4zUM"] = zUMValue4 }
                if let zLMValue4 = row["4zLM"].flatMap(Double.init) { featureDictionary["4zLM"] = zLMValue4 }
                
                if let dxMeValue4 = row["4dxMe"].flatMap(Double.init) { featureDictionary["4dxMe"] = dxMeValue4 }
                if let dxVrValue4 = row["4dxVr"].flatMap(Double.init) { featureDictionary["4dxVr"] = dxVrValue4 }
                if let dxMxValue4 = row["4dxMx"].flatMap(Double.init) { featureDictionary["4dxMx"] = dxMxValue4 }
                if let dxMiValue4 = row["4dxMi"].flatMap(Double.init) { featureDictionary["4dxMi"] = dxMiValue4 }
                if let dxUMValue4 = row["4dxUM"].flatMap(Double.init) { featureDictionary["4dxUM"] = dxUMValue4 }
                if let dxLMValue4 = row["4dxLM"].flatMap(Double.init) { featureDictionary["4dxLM"] = dxLMValue4 }
                if let dyMeValue4 = row["4dyMe"].flatMap(Double.init) { featureDictionary["4dyMe"] = dyMeValue4 }
                if let dyVrValue4 = row["4dyVr"].flatMap(Double.init) { featureDictionary["4dyVr"] = dyVrValue4 }
                if let dyMxValue4 = row["4dyMx"].flatMap(Double.init) { featureDictionary["4dyMx"] = dyMxValue4 }
                if let dyMnValue4 = row["4dyMn"].flatMap(Double.init) { featureDictionary["4dyMn"] = dyMnValue4 }
                if let dyUMValue4 = row["4dyUM"].flatMap(Double.init) { featureDictionary["4dyUM"] = dyUMValue4 }
                if let dyLMValue4 = row["4dyLM"].flatMap(Double.init) { featureDictionary["4dyLM"] = dyLMValue4 }
                if let dzMeValue4 = row["4dzMe"].flatMap(Double.init) { featureDictionary["4dzMe"] = dzMeValue4 }
                if let dzVrValue4 = row["4dzVr"].flatMap(Double.init) { featureDictionary["4dzVr"] = dzVrValue4 }
                if let dzMxValue4 = row["4dzMx"].flatMap(Double.init) { featureDictionary["4dzMx"] = dzMxValue4 }
                if let dzMiValue4 = row["4dzMi"].flatMap(Double.init) { featureDictionary["4dzMi"] = dzMiValue4 }
                if let dzUMValue4 = row["4dzUM"].flatMap(Double.init) { featureDictionary["4dzUM"] = dzUMValue4 }
                if let dzLMValue4 = row["4dzLM"].flatMap(Double.init) { featureDictionary["4dzLM"] = dzLMValue4 }
                
                if let xMeValue5 = row["5xMe"].flatMap(Double.init) { featureDictionary["5xMe"] = xMeValue5 }
                if let xVrValue5 = row["5xVr"].flatMap(Double.init) { featureDictionary["5xVr"] = xVrValue5 }
                if let xMxValue5 = row["5xMx"].flatMap(Double.init) { featureDictionary["5xMx"] = xMxValue5 }
                if let xMiValue5 = row["5xMi"].flatMap(Double.init) { featureDictionary["5xMi"] = xMiValue5 }
                if let xUMValue5 = row["5xUM"].flatMap(Double.init) { featureDictionary["5xUM"] = xUMValue5 }
                if let xLMValue5 = row["5xLM"].flatMap(Double.init) { featureDictionary["5xLM"] = xLMValue5 }
                if let yMeValue5 = row["5yMe"].flatMap(Double.init) { featureDictionary["5yMe"] = yMeValue5 }
                if let yVrValue5 = row["5yVr"].flatMap(Double.init) { featureDictionary["5yVr"] = yVrValue5 }
                if let yMxValue5 = row["5yMx"].flatMap(Double.init) { featureDictionary["5yMx"] = yMxValue5 }
                if let yMnValue5 = row["5yMn"].flatMap(Double.init) { featureDictionary["5yMn"] = yMnValue5 }
                if let yUMValue5 = row["5yUM"].flatMap(Double.init) { featureDictionary["5yUM"] = yUMValue5 }
                if let yLMValue5 = row["5yLM"].flatMap(Double.init) { featureDictionary["5yLM"] = yLMValue5 }
                if let zMeValue5 = row["5zMe"].flatMap(Double.init) { featureDictionary["5zMe"] = zMeValue5 }
                if let zVrValue5 = row["5zVr"].flatMap(Double.init) { featureDictionary["5zVr"] = zVrValue5 }
                if let zMxValue5 = row["5zMx"].flatMap(Double.init) { featureDictionary["5zMx"] = zMxValue5 }
                if let zMiValue5 = row["5zMi"].flatMap(Double.init) { featureDictionary["5zMi"] = zMiValue5 }
                if let zUMValue5 = row["5zUM"].flatMap(Double.init) { featureDictionary["5zUM"] = zUMValue5 }
                if let zLMValue5 = row["5zLM"].flatMap(Double.init) { featureDictionary["5zLM"] = zLMValue5 }
                
                if let dxMeValue5 = row["5dxMe"].flatMap(Double.init) { featureDictionary["5dxMe"] = dxMeValue5 }
                if let dxVrValue5 = row["5dxVr"].flatMap(Double.init) { featureDictionary["5dxVr"] = dxVrValue5 }
                if let dxMxValue5 = row["5dxMx"].flatMap(Double.init) { featureDictionary["5dxMx"] = dxMxValue5 }
                if let dxMiValue5 = row["5dxMi"].flatMap(Double.init) { featureDictionary["5dxMi"] = dxMiValue5 }
                if let dxUMValue5 = row["5dxUM"].flatMap(Double.init) { featureDictionary["5dxUM"] = dxUMValue5 }
                if let dxLMValue5 = row["5dxLM"].flatMap(Double.init) { featureDictionary["5dxLM"] = dxLMValue5 }
                if let dyMeValue5 = row["5dyMe"].flatMap(Double.init) { featureDictionary["5dyMe"] = dyMeValue5 }
                if let dyVrValue5 = row["5dyVr"].flatMap(Double.init) { featureDictionary["5dyVr"] = dyVrValue5 }
                if let dyMxValue5 = row["5dyMx"].flatMap(Double.init) { featureDictionary["5dyMx"] = dyMxValue5 }
                if let dyMnValue5 = row["5dyMn"].flatMap(Double.init) { featureDictionary["5dyMn"] = dyMnValue5 }
                if let dyUMValue5 = row["5dyUM"].flatMap(Double.init) { featureDictionary["5dyUM"] = dyUMValue5 }
                if let dyLMValue5 = row["5dyLM"].flatMap(Double.init) { featureDictionary["5dyLM"] = dyLMValue5 }
                if let dzMeValue5 = row["5dzMe"].flatMap(Double.init) { featureDictionary["5dzMe"] = dzMeValue5 }
                if let dzVrValue5 = row["5dzVr"].flatMap(Double.init) { featureDictionary["5dzVr"] = dzVrValue5 }
                if let dzMxValue5 = row["5dzMx"].flatMap(Double.init) { featureDictionary["5dzMx"] = dzMxValue5 }
                if let dzMiValue5 = row["5dzMi"].flatMap(Double.init) { featureDictionary["5dzMi"] = dzMiValue5 }
                if let dzUMValue5 = row["5dzUM"].flatMap(Double.init) { featureDictionary["5dzUM"] = dzUMValue5 }
                if let dzLMValue5 = row["5dzLM"].flatMap(Double.init) { featureDictionary["5dzLM"] = dzLMValue5 }
                
                if let xMeValue6 = row["6xMe"].flatMap(Double.init) { featureDictionary["6xMe"] = xMeValue6 }
                if let xVrValue6 = row["6xVr"].flatMap(Double.init) { featureDictionary["6xVr"] = xVrValue6 }
                if let xMxValue6 = row["6xMx"].flatMap(Double.init) { featureDictionary["6xMx"] = xMxValue6 }
                if let xMiValue6 = row["6xMi"].flatMap(Double.init) { featureDictionary["6xMi"] = xMiValue6 }
                if let xUMValue6 = row["6xUM"].flatMap(Double.init) { featureDictionary["6xUM"] = xUMValue6 }
                if let xLMValue6 = row["6xLM"].flatMap(Double.init) { featureDictionary["6xLM"] = xLMValue6 }
                if let yMeValue6 = row["6yMe"].flatMap(Double.init) { featureDictionary["6yMe"] = yMeValue6 }
                if let yVrValue6 = row["6yVr"].flatMap(Double.init) { featureDictionary["6yVr"] = yVrValue6 }
                if let yMxValue6 = row["6yMx"].flatMap(Double.init) { featureDictionary["6yMx"] = yMxValue6 }
                if let yMnValue6 = row["6yMn"].flatMap(Double.init) { featureDictionary["6yMn"] = yMnValue6 }
                if let yUMValue6 = row["6yUM"].flatMap(Double.init) { featureDictionary["6yUM"] = yUMValue6 }
                if let yLMValue6 = row["6yLM"].flatMap(Double.init) { featureDictionary["6yLM"] = yLMValue6 }
                if let zMeValue6 = row["6zMe"].flatMap(Double.init) { featureDictionary["6zMe"] = zMeValue6 }
                if let zVrValue6 = row["6zVr"].flatMap(Double.init) { featureDictionary["6zVr"] = zVrValue6 }
                if let zMxValue6 = row["6zMx"].flatMap(Double.init) { featureDictionary["6zMx"] = zMxValue6 }
                if let zMiValue6 = row["6zMi"].flatMap(Double.init) { featureDictionary["6zMi"] = zMiValue6 }
                if let zUMValue6 = row["6zUM"].flatMap(Double.init) { featureDictionary["6zUM"] = zUMValue6 }
                if let zLMValue6 = row["6zLM"].flatMap(Double.init) { featureDictionary["6zLM"] = zLMValue6 }
                
                if let dxMeValue6 = row["6dxMe"].flatMap(Double.init) { featureDictionary["6dxMe"] = dxMeValue6 }
                if let dxVrValue6 = row["6dxVr"].flatMap(Double.init) { featureDictionary["6dxVr"] = dxVrValue6 }
                if let dxMxValue6 = row["6dxMx"].flatMap(Double.init) { featureDictionary["6dxMx"] = dxMxValue6 }
                if let dxMiValue6 = row["6dxMi"].flatMap(Double.init) { featureDictionary["6dxMi"] = dxMiValue6 }
                if let dxUMValue6 = row["6dxUM"].flatMap(Double.init) { featureDictionary["6dxUM"] = dxUMValue6 }
                if let dxLMValue6 = row["6dxLM"].flatMap(Double.init) { featureDictionary["6dxLM"] = dxLMValue6 }
                if let dyMeValue6 = row["6dyMe"].flatMap(Double.init) { featureDictionary["6dyMe"] = dyMeValue6 }
                if let dyVrValue6 = row["6dyVr"].flatMap(Double.init) { featureDictionary["6dyVr"] = dyVrValue6 }
                if let dyMxValue6 = row["6dyMx"].flatMap(Double.init) { featureDictionary["6dyMx"] = dyMxValue6 }
                if let dyMnValue6 = row["6dyMn"].flatMap(Double.init) { featureDictionary["6dyMn"] = dyMnValue6 }
                if let dyUMValue6 = row["6dyUM"].flatMap(Double.init) { featureDictionary["6dyUM"] = dyUMValue6 }
                if let dyLMValue6 = row["6dyLM"].flatMap(Double.init) { featureDictionary["6dyLM"] = dyLMValue6 }
                if let dzMeValue6 = row["6dzMe"].flatMap(Double.init) { featureDictionary["6dzMe"] = dzMeValue6 }
                if let dzVrValue6 = row["6dzVr"].flatMap(Double.init) { featureDictionary["6dzVr"] = dzVrValue6 }
                if let dzMxValue6 = row["6dzMx"].flatMap(Double.init) { featureDictionary["6dzMx"] = dzMxValue6 }
                if let dzMiValue6 = row["6dzMi"].flatMap(Double.init) { featureDictionary["6dzMi"] = dzMiValue6 }
                if let dzUMValue6 = row["6dzUM"].flatMap(Double.init) { featureDictionary["6dzUM"] = dzUMValue6 }
                if let dzLMValue6 = row["6dzLM"].flatMap(Double.init) { featureDictionary["6dzLM"] = dzLMValue6 }
                
                if let xMeValue7 = row["7xMe"].flatMap(Double.init) { featureDictionary["7xMe"] = xMeValue7 }
                if let xVrValue7 = row["7xVr"].flatMap(Double.init) { featureDictionary["7xVr"] = xVrValue7 }
                if let xMxValue7 = row["7xMx"].flatMap(Double.init) { featureDictionary["7xMx"] = xMxValue7 }
                if let xMiValue7 = row["7xMi"].flatMap(Double.init) { featureDictionary["7xMi"] = xMiValue7 }
                if let xUMValue7 = row["7xUM"].flatMap(Double.init) { featureDictionary["7xUM"] = xUMValue7 }
                if let xLMValue7 = row["7xLM"].flatMap(Double.init) { featureDictionary["7xLM"] = xLMValue7 }
                if let yMeValue7 = row["7yMe"].flatMap(Double.init) { featureDictionary["7yMe"] = yMeValue7 }
                if let yVrValue7 = row["7yVr"].flatMap(Double.init) { featureDictionary["7yVr"] = yVrValue7 }
                if let yMxValue7 = row["7yMx"].flatMap(Double.init) { featureDictionary["7yMx"] = yMxValue7 }
                if let yMnValue7 = row["7yMn"].flatMap(Double.init) { featureDictionary["7yMn"] = yMnValue7 }
                if let yUMValue7 = row["7yUM"].flatMap(Double.init) { featureDictionary["7yUM"] = yUMValue7 }
                if let yLMValue7 = row["7yLM"].flatMap(Double.init) { featureDictionary["7yLM"] = yLMValue7 }
                if let zMeValue7 = row["7zMe"].flatMap(Double.init) { featureDictionary["7zMe"] = zMeValue7 }
                if let zVrValue7 = row["7zVr"].flatMap(Double.init) { featureDictionary["7zVr"] = zVrValue7 }
                if let zMxValue7 = row["7zMx"].flatMap(Double.init) { featureDictionary["7zMx"] = zMxValue7 }
                if let zMiValue7 = row["7zMi"].flatMap(Double.init) { featureDictionary["7zMi"] = zMiValue7 }
                if let zUMValue7 = row["7zUM"].flatMap(Double.init) { featureDictionary["7zUM"] = zUMValue7 }
                if let zLMValue7 = row["7zLM"].flatMap(Double.init) { featureDictionary["7zLM"] = zLMValue7 }
                
                if let dxMeValue7 = row["7dxMe"].flatMap(Double.init) { featureDictionary["7dxMe"] = dxMeValue7 }
                if let dxVrValue7 = row["7dxVr"].flatMap(Double.init) { featureDictionary["7dxVr"] = dxVrValue7 }
                if let dxMxValue7 = row["7dxMx"].flatMap(Double.init) { featureDictionary["7dxMx"] = dxMxValue7 }
                if let dxMiValue7 = row["7dxMi"].flatMap(Double.init) { featureDictionary["7dxMi"] = dxMiValue7 }
                if let dxUMValue7 = row["7dxUM"].flatMap(Double.init) { featureDictionary["7dxUM"] = dxUMValue7 }
                if let dxLMValue7 = row["7dxLM"].flatMap(Double.init) { featureDictionary["7dxLM"] = dxLMValue7 }
                if let dyMeValue7 = row["7dyMe"].flatMap(Double.init) { featureDictionary["7dyMe"] = dyMeValue7 }
                if let dyVrValue7 = row["7dyVr"].flatMap(Double.init) { featureDictionary["7dyVr"] = dyVrValue7 }
                if let dyMxValue7 = row["7dyMx"].flatMap(Double.init) { featureDictionary["7dyMx"] = dyMxValue7 }
                if let dyMnValue7 = row["7dyMn"].flatMap(Double.init) { featureDictionary["7dyMn"] = dyMnValue7 }
                if let dyUMValue7 = row["7dyUM"].flatMap(Double.init) { featureDictionary["7dyUM"] = dyUMValue7 }
                if let dyLMValue7 = row["7dyLM"].flatMap(Double.init) { featureDictionary["7dyLM"] = dyLMValue7 }
                if let dzMeValue7 = row["7dzMe"].flatMap(Double.init) { featureDictionary["7dzMe"] = dzMeValue7 }
                if let dzVrValue7 = row["7dzVr"].flatMap(Double.init) { featureDictionary["7dzVr"] = dzVrValue7 }
                if let dzMxValue7 = row["7dzMx"].flatMap(Double.init) { featureDictionary["7dzMx"] = dzMxValue7 }
                if let dzMiValue7 = row["7dzMi"].flatMap(Double.init) { featureDictionary["7dzMi"] = dzMiValue7 }
                if let dzUMValue7 = row["7dzUM"].flatMap(Double.init) { featureDictionary["7dzUM"] = dzUMValue7 }
                if let dzLMValue7 = row["7dzLM"].flatMap(Double.init) { featureDictionary["7dzLM"] = dzLMValue7 }
                
                let modelInput = alcoholInput(
                    _0xMe: featureDictionary["0xMe"] ?? 0.0,
                    _0xVr: featureDictionary["0xVr"] ?? 0.0,
                    _0xMx: featureDictionary["0xMx"] ?? 0.0,
                    _0xMi: featureDictionary["0xMi"] ?? 0.0,
                    _0xUM: featureDictionary["0xUM"] ?? 0.0,
                    _0xLM: featureDictionary["0xLM"] ?? 0.0,
                    _0yMe: featureDictionary["0yMe"] ?? 0.0,
                    _0yVr: featureDictionary["0yVr"] ?? 0.0,
                    _0yMx: featureDictionary["0yMx"] ?? 0.0,
                    _0yMn: featureDictionary["0yMn"] ?? 0.0,
                    _0yUM: featureDictionary["0yUM"] ?? 0.0,
                    _0yLM: featureDictionary["0yLM"] ?? 0.0,
                    _0zMe: featureDictionary["0zMe"] ?? 0.0,
                    _0zVr: featureDictionary["0zVr"] ?? 0.0,
                    _0zMx: featureDictionary["0zMx"] ?? 0.0,
                    _0zMi: featureDictionary["0zMi"] ?? 0.0,
                    _0zUM: featureDictionary["0zUM"] ?? 0.0,
                    _0zLM: featureDictionary["0zLM"] ?? 0.0,
                    d0xMe: featureDictionary["0dxMe"] ?? 0.0,
                    d0xVr: featureDictionary["0dxVr"] ?? 0.0,
                    d0xMx: featureDictionary["0dxMx"] ?? 0.0,
                    d0xMi: featureDictionary["0dxMi"] ?? 0.0,
                    d0xUM: featureDictionary["0dxUM"] ?? 0.0,
                    d0xLM: featureDictionary["0dxLM"] ?? 0.0,
                    d0yMe: featureDictionary["0dyMe"] ?? 0.0,
                    d0yVr: featureDictionary["0dyVr"] ?? 0.0,
                    d0yMx: featureDictionary["0dyMx"] ?? 0.0,
                    d0yMn: featureDictionary["0dyMn"] ?? 0.0,
                    d0yUM: featureDictionary["0dyUM"] ?? 0.0,
                    d0yLM: featureDictionary["0dyLM"] ?? 0.0,
                    d0zMe: featureDictionary["0dzMe"] ?? 0.0,
                    d0zVr: featureDictionary["0dzVr"] ?? 0.0,
                    d0zMx: featureDictionary["0dzMx"] ?? 0.0,
                    d0zMi: featureDictionary["0dzMi"] ?? 0.0,
                    d0zUM: featureDictionary["0dzUM"] ?? 0.0,
                    d0zLM: featureDictionary["0dzLM"] ?? 0.0,
                    _1xMe: featureDictionary["1xMe"] ?? 0.0,
                    _1xVr: featureDictionary["1xVr"] ?? 0.0,
                    _1xMx: featureDictionary["1xMx"] ?? 0.0,
                    _1xMi: featureDictionary["1xMi"] ?? 0.0,
                    _1xUM: featureDictionary["1xUM"] ?? 0.0,
                    _1xLM: featureDictionary["1xLM"] ?? 0.0,
                    _1yMe: featureDictionary["1yMe"] ?? 0.0,
                    _1yVr: featureDictionary["1yVr"] ?? 0.0,
                    _1yMx: featureDictionary["1yMx"] ?? 0.0,
                    _1yMn: featureDictionary["1yMn"] ?? 0.0,
                    _1yUM: featureDictionary["1yUM"] ?? 0.0,
                    _1yLM: featureDictionary["1yLM"] ?? 0.0,
                    _1zMe: featureDictionary["1zMe"] ?? 0.0,
                    _1zVr: featureDictionary["1zVr"] ?? 0.0,
                    _1zMx: featureDictionary["1zMx"] ?? 0.0,
                    _1zMi: featureDictionary["1zMi"] ?? 0.0,
                    _1zUM: featureDictionary["1zUM"] ?? 0.0,
                    _1zLM: featureDictionary["1zLM"] ?? 0.0,
                    d1xMe: featureDictionary["1dxMe"] ?? 0.0,
                    d1xVr: featureDictionary["1dxVr"] ?? 0.0,
                    d1xMx: featureDictionary["1dxMx"] ?? 0.0,
                    d1xMi: featureDictionary["1dxMi"] ?? 0.0,
                    d1xUM: featureDictionary["1dxUM"] ?? 0.0,
                    d1xLM: featureDictionary["1dxLM"] ?? 0.0,
                    d1yMe: featureDictionary["1dyMe"] ?? 0.0,
                    d1yVr: featureDictionary["1dyVr"] ?? 0.0,
                    d1yMx: featureDictionary["1dyMx"] ?? 0.0,
                    d1yMn: featureDictionary["1dyMn"] ?? 0.0,
                    d1yUM: featureDictionary["1dyUM"] ?? 0.0,
                    d1yLM: featureDictionary["1dyLM"] ?? 0.0,
                    d1zMe: featureDictionary["1dzMe"] ?? 0.0,
                    d1zVr: featureDictionary["1dzVr"] ?? 0.0,
                    d1zMx: featureDictionary["1dzMx"] ?? 0.0,
                    d1zMi: featureDictionary["1dzMi"] ?? 0.0,
                    d1zUM: featureDictionary["1dzUM"] ?? 0.0,
                    d1zLM: featureDictionary["1dzLM"] ?? 0.0,
                    _2xMe: featureDictionary["2xMe"] ?? 0.0,
                    _2xVr: featureDictionary["2xVr"] ?? 0.0,
                    _2xMx: featureDictionary["2xMx"] ?? 0.0,
                    _2xMi: featureDictionary["2xMi"] ?? 0.0,
                    _2xUM: featureDictionary["2xUM"] ?? 0.0,
                    _2xLM: featureDictionary["2xLM"] ?? 0.0,
                    _2yMe: featureDictionary["2yMe"] ?? 0.0,
                    _2yVr: featureDictionary["2yVr"] ?? 0.0,
                    _2yMx: featureDictionary["2yMx"] ?? 0.0,
                    _2yMn: featureDictionary["2yMn"] ?? 0.0,
                    _2yUM: featureDictionary["2yUM"] ?? 0.0,
                    _2yLM: featureDictionary["2yLM"] ?? 0.0,
                    _2zMe: featureDictionary["2zMe"] ?? 0.0,
                    _2zVr: featureDictionary["2zVr"] ?? 0.0,
                    _2zMx: featureDictionary["2zMx"] ?? 0.0,
                    _2zMi: featureDictionary["2zMi"] ?? 0.0,
                    _2zUM: featureDictionary["2zUM"] ?? 0.0,
                    _2zLM: featureDictionary["2zLM"] ?? 0.0,
                    d2xMe: featureDictionary["2dxMe"] ?? 0.0,
                    d2xVr: featureDictionary["2dxVr"] ?? 0.0,
                    d2xMx: featureDictionary["2dxMx"] ?? 0.0,
                    d2xMi: featureDictionary["2dxMi"] ?? 0.0,
                    d2xUM: featureDictionary["2dxUM"] ?? 0.0,
                    d2xLM: featureDictionary["2dxLM"] ?? 0.0,
                    d2yMe: featureDictionary["2dyMe"] ?? 0.0,
                    d2yVr: featureDictionary["2dyVr"] ?? 0.0,
                    d2yMx: featureDictionary["2dyMx"] ?? 0.0,
                    d2yMn: featureDictionary["2dyMn"] ?? 0.0,
                    d2yUM: featureDictionary["2dyUM"] ?? 0.0,
                    d2yLM: featureDictionary["2dyLM"] ?? 0.0,
                    d2zMe: featureDictionary["2dzMe"] ?? 0.0,
                    d2zVr: featureDictionary["2dzVr"] ?? 0.0,
                    d2zMx: featureDictionary["2dzMx"] ?? 0.0,
                    d2zMi: featureDictionary["2dzMi"] ?? 0.0,
                    d2zUM: featureDictionary["2dzUM"] ?? 0.0,
                    d2zLM: featureDictionary["2dzLM"] ?? 0.0,
                    _4xMe: featureDictionary["4xMe"] ?? 0.0,
                    _4xVr: featureDictionary["4xVr"] ?? 0.0,
                    _4xMx: featureDictionary["4xMx"] ?? 0.0,
                    _4xMi: featureDictionary["4xMi"] ?? 0.0,
                    _4xUM: featureDictionary["4xUM"] ?? 0.0,
                    _4xLM: featureDictionary["4xLM"] ?? 0.0,
                    _4yMe: featureDictionary["4yMe"] ?? 0.0,
                    _4yVr: featureDictionary["4yVr"] ?? 0.0,
                    _4yMx: featureDictionary["4yMx"] ?? 0.0,
                    _4yMn: featureDictionary["4yMn"] ?? 0.0,
                    _4yUM: featureDictionary["4yUM"] ?? 0.0,
                    _4yLM: featureDictionary["4yLM"] ?? 0.0,
                    _4zMe: featureDictionary["4zMe"] ?? 0.0,
                    _4zVr: featureDictionary["4zVr"] ?? 0.0,
                    _4zMx: featureDictionary["4zMx"] ?? 0.0,
                    _4zMi: featureDictionary["4zMi"] ?? 0.0,
                    _4zUM: featureDictionary["4zUM"] ?? 0.0,
                    _4zLM: featureDictionary["4zLM"] ?? 0.0,
                    d4xMe: featureDictionary["4dxMe"] ?? 0.0,
                    d4xVr: featureDictionary["4dxVr"] ?? 0.0,
                    d4xMx: featureDictionary["4dxMx"] ?? 0.0,
                    d4xMi: featureDictionary["4dxMi"] ?? 0.0,
                    d4xUM: featureDictionary["4dxUM"] ?? 0.0,
                    d4xLM: featureDictionary["4dxLM"] ?? 0.0,
                    d4yMe: featureDictionary["4dyMe"] ?? 0.0,
                    d4yVr: featureDictionary["4dyVr"] ?? 0.0,
                    d4yMx: featureDictionary["4dyMx"] ?? 0.0,
                    d4yMn: featureDictionary["4dyMn"] ?? 0.0,
                    d4yUM: featureDictionary["4dyUM"] ?? 0.0,
                    d4yLM: featureDictionary["4dyLM"] ?? 0.0,
                    d4zMe: featureDictionary["4dzMe"] ?? 0.0,
                    d4zVr: featureDictionary["4dzVr"] ?? 0.0,
                    d4zMx: featureDictionary["4dzMx"] ?? 0.0,
                    d4zMi: featureDictionary["4dzMi"] ?? 0.0,
                    d4zUM: featureDictionary["4dzUM"] ?? 0.0,
                    d4zLM: featureDictionary["4dzLM"] ?? 0.0,
                    _5xMe: featureDictionary["5xMe"] ?? 0.0,
                    _5xVr: featureDictionary["5xVr"] ?? 0.0,
                    _5xMx: featureDictionary["5xMx"] ?? 0.0,
                    _5xMi: featureDictionary["5xMi"] ?? 0.0,
                    _5xUM: featureDictionary["5xUM"] ?? 0.0,
                    _5xLM: featureDictionary["5xLM"] ?? 0.0,
                    _5yMe: featureDictionary["5yMe"] ?? 0.0,
                    _5yVr: featureDictionary["5yVr"] ?? 0.0,
                    _5yMx: featureDictionary["5yMx"] ?? 0.0,
                    _5yMn: featureDictionary["5yMn"] ?? 0.0,
                    _5yUM: featureDictionary["5yUM"] ?? 0.0,
                    _5yLM: featureDictionary["5yLM"] ?? 0.0,
                    _5zMe: featureDictionary["5zMe"] ?? 0.0,
                    _5zVr: featureDictionary["5zVr"] ?? 0.0,
                    _5zMx: featureDictionary["5zMx"] ?? 0.0,
                    _5zMi: featureDictionary["5zMi"] ?? 0.0,
                    _5zUM: featureDictionary["5zUM"] ?? 0.0,
                    _5zLM: featureDictionary["5zLM"] ?? 0.0,
                    d5xMe: featureDictionary["5dxMe"] ?? 0.0,
                    d5xVr: featureDictionary["5dxVr"] ?? 0.0,
                    d5xMx: featureDictionary["5dxMx"] ?? 0.0,
                    d5xMi: featureDictionary["5dxMi"] ?? 0.0,
                    d5xUM: featureDictionary["5dxUM"] ?? 0.0,
                    d5xLM: featureDictionary["5dxLM"] ?? 0.0,
                    d5yMe: featureDictionary["5dyMe"] ?? 0.0,
                    d5yVr: featureDictionary["5dyVr"] ?? 0.0,
                    d5yMx: featureDictionary["5dyMx"] ?? 0.0,
                    d5yMn: featureDictionary["5dyMn"] ?? 0.0,
                    d5yUM: featureDictionary["5dyUM"] ?? 0.0,
                    d5yLM: featureDictionary["5dyLM"] ?? 0.0,
                    d5zMe: featureDictionary["5dzMe"] ?? 0.0,
                    d5zVr: featureDictionary["5dzVr"] ?? 0.0,
                    d5zMx: featureDictionary["5dzMx"] ?? 0.0,
                    d5zMi: featureDictionary["5dzMi"] ?? 0.0,
                    d5zUM: featureDictionary["5dzUM"] ?? 0.0,
                    d5zLM: featureDictionary["5dzLM"] ?? 0.0,
                    _6xMe: featureDictionary["6xMe"] ?? 0.0,
                    _6xVr: featureDictionary["6xVr"] ?? 0.0,
                    _6xMx: featureDictionary["6xMx"] ?? 0.0,
                    _6xMi: featureDictionary["6xMi"] ?? 0.0,
                    _6xUM: featureDictionary["6xUM"] ?? 0.0,
                    _6xLM: featureDictionary["6xLM"] ?? 0.0,
                    _6yMe: featureDictionary["6yMe"] ?? 0.0,
                    _6yVr: featureDictionary["6yVr"] ?? 0.0,
                    _6yMx: featureDictionary["6yMx"] ?? 0.0,
                    _6yMn: featureDictionary["6yMn"] ?? 0.0,
                    _6yUM: featureDictionary["6yUM"] ?? 0.0,
                    _6yLM: featureDictionary["6yLM"] ?? 0.0,
                    _6zMe: featureDictionary["6zMe"] ?? 0.0,
                    _6zVr: featureDictionary["6zVr"] ?? 0.0,
                    _6zMx: featureDictionary["6zMx"] ?? 0.0,
                    _6zMi: featureDictionary["6zMi"] ?? 0.0,
                    _6zUM: featureDictionary["6zUM"] ?? 0.0,
                    _6zLM: featureDictionary["6zLM"] ?? 0.0,
                    d6xMe: featureDictionary["6dxMe"] ?? 0.0,
                    d6xVr: featureDictionary["6dxVr"] ?? 0.0,
                    d6xMx: featureDictionary["6dxMx"] ?? 0.0,
                    d6xMi: featureDictionary["6dxMi"] ?? 0.0,
                    d6xUM: featureDictionary["6dxUM"] ?? 0.0,
                    d6xLM: featureDictionary["6dxLM"] ?? 0.0,
                    d6yMe: featureDictionary["6dyMe"] ?? 0.0,
                    d6yVr: featureDictionary["6dyVr"] ?? 0.0,
                    d6yMx: featureDictionary["6dyMx"] ?? 0.0,
                    d6yMn: featureDictionary["6dyMn"] ?? 0.0,
                    d6yUM: featureDictionary["6dyUM"] ?? 0.0,
                    d6yLM: featureDictionary["6dyLM"] ?? 0.0,
                    d6zMe: featureDictionary["6dzMe"] ?? 0.0,
                    d6zVr: featureDictionary["6dzVr"] ?? 0.0,
                    d6zMx: featureDictionary["6dzMx"] ?? 0.0,
                    d6zMi: featureDictionary["6dzMi"] ?? 0.0,
                    d6zUM: featureDictionary["6dzUM"] ?? 0.0,
                    d6zLM: featureDictionary["6dzLM"] ?? 0.0,
                    _7xMe: featureDictionary["7xMe"] ?? 0.0,
                    _7xVr: featureDictionary["7xVr"] ?? 0.0,
                    _7xMx: featureDictionary["7xMx"] ?? 0.0,
                    _7xMi: featureDictionary["7xMi"] ?? 0.0,
                    _7xUM: featureDictionary["7xUM"] ?? 0.0,
                    _7xLM: featureDictionary["7xLM"] ?? 0.0,
                    _7yMe: featureDictionary["7yMe"] ?? 0.0,
                    _7yVr: featureDictionary["7yVr"] ?? 0.0,
                    _7yMx: featureDictionary["7yMx"] ?? 0.0,
                    _7yMn: featureDictionary["7yMn"] ?? 0.0,
                    _7yUM: featureDictionary["7yUM"] ?? 0.0,
                    _7yLM: featureDictionary["7yLM"] ?? 0.0,
                    _7zMe: featureDictionary["7zMe"] ?? 0.0,
                    _7zVr: featureDictionary["7zVr"] ?? 0.0,
                    _7zMx: featureDictionary["7zMx"] ?? 0.0,
                    _7zMi: featureDictionary["7zMi"] ?? 0.0,
                    _7zUM: featureDictionary["7zUM"] ?? 0.0,
                    _7zLM: featureDictionary["7zLM"] ?? 0.0,
                    d7xMe: featureDictionary["7dxMe"] ?? 0.0,
                    d7xVr: featureDictionary["7dxVr"] ?? 0.0,
                    d7xMx: featureDictionary["7dxMx"] ?? 0.0,
                    d7xMi: featureDictionary["7dxMi"] ?? 0.0,
                    d7xUM: featureDictionary["7dxUM"] ?? 0.0,
                    d7xLM: featureDictionary["7dxLM"] ?? 0.0,
                    d7yMe: featureDictionary["7dyMe"] ?? 0.0,
                    d7yVr: featureDictionary["7dyVr"] ?? 0.0,
                    d7yMx: featureDictionary["7dyMx"] ?? 0.0,
                    d7yMn: featureDictionary["7dyMn"] ?? 0.0,
                    d7yUM: featureDictionary["7dyUM"] ?? 0.0,
                    d7yLM: featureDictionary["7dyLM"] ?? 0.0,
                    d7zMe: featureDictionary["7dzMe"] ?? 0.0,
                    d7zVr: featureDictionary["7dzVr"] ?? 0.0,
                    d7zMx: featureDictionary["7dzMx"] ?? 0.0,
                    d7zMi: featureDictionary["7dzMi"] ?? 0.0,
                    d7zUM: featureDictionary["7dzUM"] ?? 0.0,
                    d7zLM: featureDictionary["7dzLM"] ?? 0.0)
                
//                print("model input:")
//                let mirror = Mirror(reflecting: modelInput)
//                for child in mirror.children {
//                    print("\(child.label!): \(child.value)")
//                }
                
                let prediction = try! model.prediction(input: modelInput)
                print("Current Level: ", prediction.TAC_Reading)
                return Int(prediction.TAC_Reading)
            }
        }
        print("Error in predicting level")
        return 0;
    }
}
