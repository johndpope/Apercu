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
    
    func createMainPlotData(bpm: [Double], time: [Double], minTime: Double, maxTime: Double) -> [[CPTScatterPlotField: Double]] {
        var plotData = [[CPTScatterPlotField: Double]]()

        var dataSet = averageRawData(bpm, time: time, minTime: minTime, maxTime: maxTime)
        let modifiedBpm = dataSet[0]
        var modifiedTime = dataSet[1]
        
        for (index, element) in modifiedBpm.enumerate() {
            plotData.append([CPTScatterPlotField.X: modifiedTime[index], CPTScatterPlotField.Y: element])
        }
        
        return plotData
    }
    
    func createAveragePlotData(averageBpm: Double, duration: Double) -> [[CPTScatterPlotField: Double]] {
        
        return [[CPTScatterPlotField.X: 0, CPTScatterPlotField.Y: averageBpm], [CPTScatterPlotField.X: duration, CPTScatterPlotField.Y: averageBpm]]
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
            plotData.append([CPTScatterPlotField.X: time[index], CPTScatterPlotField.Y: element])
        }
        
        return plotData
    }
}