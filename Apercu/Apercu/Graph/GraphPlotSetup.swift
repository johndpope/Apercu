//
//  GraphPlotSetup.swift
//  Apercu
//
//  Created by David Lantrip on 1/2/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import UIKit
import CorePlot

class GraphPlotSetup {
    
    var emptyLineStyle: CPTMutableLineStyle!
    
    init() {
        emptyLineStyle = CPTMutableLineStyle()
        emptyLineStyle.lineWidth = 0.0
    }
    
    func detailPlotSetup() -> [CPTScatterPlot] {
        var plots = [CPTScatterPlot]()
        plots.append(createMainPlot())
        plots.append(createAveragePlot())
        plots.append(createTopFillPlot())
        plots.append(createBottomFillPlot())
        plots.append(createZeroPlot())
        
        return plots
    }
    
    func mostActivePlotSetu() -> CPTScatterPlot {
        return createMostActivePlot() 
    }
    
    func createMainPlot() -> CPTScatterPlot {
        let mainLineStyle = CPTMutableLineStyle()
        mainLineStyle.lineWidth = 2.2
        mainLineStyle.lineColor = CPTColor.whiteColor()
        
        let mainPlot = CPTScatterPlot()
        mainPlot.identifier = "Main Plot";
        mainPlot.interpolation = .Curved
        mainPlot.dataLineStyle = mainLineStyle
        
        return mainPlot
    }
    
    func createAveragePlot() -> CPTScatterPlot {
        let averageLineColor = CPTColor(componentRed: 0.94, green: 0.91, blue: 0.91, alpha: 1)
        
        let averageLineStyle = CPTMutableLineStyle()
        averageLineStyle.lineWidth = 1.0
        averageLineStyle.dashPattern = [5, 5]
        averageLineStyle.lineColor = averageLineColor
        
        let averagePlot = CPTScatterPlot()
        averagePlot.identifier = "AvegPlot"
        averagePlot.dataLineStyle = averageLineStyle
        
        return averagePlot
    }
    
    func createTopFillPlot() -> CPTScatterPlot {
        let topFillColor = CPTColor(componentRed: 250.0/255.0, green: 0.0, blue: 0.0, alpha: 0.6)
        
        let topFillPlot = CPTScatterPlot()
        topFillPlot.identifier = "Top Fill"
        topFillPlot.dataLineStyle = emptyLineStyle
        topFillPlot.areaBaseValue = IntensityThresholdSingleton.sharedInstance.highIntensityThreshold
        topFillPlot.areaFill = CPTFill(color: topFillColor)
        
        return topFillPlot
    }
    
    func createBottomFillPlot() -> CPTScatterPlot {
        let bottomFillColor = CPTColor(componentRed: 250.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 0.35)
        
        let bottomFillPlot = CPTScatterPlot()
        bottomFillPlot.identifier = "Bottom Fill"
        bottomFillPlot.dataLineStyle = emptyLineStyle
        bottomFillPlot.areaBaseValue = IntensityThresholdSingleton.sharedInstance.highIntensityThreshold
        bottomFillPlot.areaFill = CPTFill(color: bottomFillColor)
        
        return bottomFillPlot
    }
    
    func createMostActivePlot() -> CPTScatterPlot {
        let activeLineColor = CPTColor(componentRed: 249.0/255.0, green: 228.0/255.0, blue: 127.0/255.0, alpha: 0.6)
        
        let activeLineStyle = CPTMutableLineStyle()
        activeLineStyle.lineColor = activeLineColor
        activeLineStyle.lineWidth = 2.0
        
        let mostActivePlot = CPTScatterPlot()
        mostActivePlot.identifier = "Active"
        mostActivePlot.dataLineStyle = emptyLineStyle
        
        return mostActivePlot
    }
    
    func createZeroPlot() -> CPTScatterPlot {
        let zeroLineStyle = CPTMutableLineStyle()
        zeroLineStyle.lineColor = CPTColor.whiteColor()
        zeroLineStyle.lineWidth = 1.0
        zeroLineStyle.dashPattern = [5, 5]
        
        let zeroPlot = CPTScatterPlot()
        zeroPlot.identifier = "Zero PLot"
        zeroPlot.dataLineStyle = zeroLineStyle
        
        return zeroPlot
    }
    
    func createHeatmapPlot(colorNumber: [Double], time: [Double], yMin: Double, yMax: Double) -> [ApercuPlot] {
        var heatmapPlots = [ApercuPlot]()
        
        let emptyLineStyle = CPTMutableLineStyle()
        emptyLineStyle.lineWidth = 0.0
        
        let color1 = CPTColor(componentRed: 74.0/255.0, green: 170.0/255.0, blue: 214.0/155.0, alpha: 0.8)
        let color2 = CPTColor(componentRed: 138.0/255.0, green: 188.0/255.0, blue: 209.0/255.0, alpha: 0.8)
        let color3 = CPTColor(componentRed: 148.0/255.0, green: 158.0/255.0, blue: 163.0/255.0, alpha: 0.8)
        let color4 = CPTColor(componentRed: 209.0/255.0, green: 148.0/255.0, blue: 158.0/255.0, alpha: 0.8)
        let color5 = CPTColor(componentRed: 209.0/255.0, green: 95.0/255.0, blue: 102.0/255.0, alpha: 0.8)
        let colors = [color1, color2, color3, color4, color5, color5]
        
        for (index, element) in colorNumber.enumerate() {
            let xMin = time[index]
            var xMax: Double!
            
            if index != colorNumber.count {
                xMax = time[index + 1]
            } else {
                xMax = time.last
            }
            
            let plotData = [[CPTScatterPlotField.X: xMin, CPTScatterPlotField.Y: yMin], [CPTScatterPlotField.X: xMin, CPTScatterPlotField.Y: yMax], [CPTScatterPlotField.X: xMax, CPTScatterPlotField.Y: yMax], [CPTScatterPlotField.X: xMax, CPTScatterPlotField.Y: yMin]]
            
            let plot = CPTScatterPlot()
            plot.identifier = String(format: "%lu", index)
            plot.areaBaseValue = 0
            plot.areaFill = CPTFill(color: colors[Int(element)])
            
            heatmapPlots.append(ApercuPlot(plot: plot, data: plotData))
        }
        
        
        return heatmapPlots
    }
    
}