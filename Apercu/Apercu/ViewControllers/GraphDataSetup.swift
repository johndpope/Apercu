//
//  GraphDataSetup.swift
//  Apercu
//
//  Created by David Lantrip on 1/2/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import CorePlot

class GraphDataSetup {
    
    func detailDataSetup() -> [[CPTScatterPlotField: Double]] {
        var plotData = [[CPTScatterPlotField: Double]]()
        
        
        return plotData
    }
    
    func createMainPlotData(bpm: [Double], time: [Double]) -> [[CPTScatterPlotField: Double]] {
        var plotData = [[CPTScatterPlotField: Double]]()
        
        for (index, element) in bpm.enumerate() {
            plotData.append([CPTScatterPlotField.X: element, CPTScatterPlotField.Y: time[index]])
        }
        
        return plotData
    }
    
    func createAveragePlotData(averageBpm: Double, duration: Double) -> [[CPTScatterPlotField: Double]] {
        
        return [[CPTScatterPlotField.X: 0, CPTScatterPlotField.Y: averageBpm], [CPTScatterPlotField.X: duration, CPTScatterPlotField.Y: averageBpm]]
    }
    
    func createTopFillPlotData(duration: Double) -> [[CPTScatterPlotField: Double]] {
        let highIntensityMax = IntensityThresholdSingleton.sharedInstance.maximumHeatRate * 0.9
        
        return [[CPTScatterPlotField.X: 0, CPTScatterPlotField.Y: highIntensityMax], [CPTScatterPlotField.X: duration, CPTScatterPlotField.Y: highIntensityMax]]
    }
    
    func createBottomFillPlotData(duration: Double) -> [[CPTScatterPlotField: Double]] {
        let moderateIntensityMin = IntensityThresholdSingleton.sharedInstance.moderateIntensityThreshold
        
        return [[CPTScatterPlotField.X: 0, CPTScatterPlotField.Y: moderateIntensityMin], [CPTScatterPlotField.X: duration, CPTScatterPlotField.Y: moderateIntensityMin]]
    }
    
    func createMostActivePlotData(start: Double, end: Double, max: Double, min: Double) -> [[CPTScatterPlotField: Double]] {
        
        return [[CPTScatterPlotField.X: start, CPTScatterPlotField.Y: min], [CPTScatterPlotField.X: start, CPTScatterPlotField.Y: max], [CPTScatterPlotField.X: end, CPTScatterPlotField.Y: max], [CPTScatterPlotField.X: end, CPTScatterPlotField.Y: min]]
    }
    
    func createZeroLineData(duration: Double) -> [[CPTScatterPlotField: Double]] {
        
        return [[CPTScatterPlotField.X: 0, CPTScatterPlotField.Y: 0], [CPTScatterPlotField.X: duration, CPTScatterPlotField.Y: 0]]
    }
    
    func createHeatmapPlotData(colorIndex: [Double], time: [Double]) -> [[CPTScatterPlotField: Double]] {
        
        var plotData = [[CPTScatterPlotField: Double]]()
        
        for (index, element) in colorIndex.enumerate() {
            plotData.append([CPTScatterPlotField.X: element, CPTScatterPlotField.Y: time[index]])
        }
        
        return plotData
    }
}