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

        return plots
    }
    
    func createMainPlot() -> CPTScatterPlot {
        let mainLineStyle = CPTMutableLineStyle()
        mainLineStyle.lineWidth = 2.2
        mainLineStyle.lineColor = CPTColor.whiteColor()
        
        let mainPlot = CPTScatterPlot()
        mainPlot.identifier = "Main";
        mainPlot.interpolation = .Linear
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
        averagePlot.identifier = "Average"
        averagePlot.dataLineStyle = averageLineStyle
        
        return averagePlot
    }
    
    func createMostActivePlot(min: Double) -> CPTScatterPlot {
        let activeLineColor = CPTColor(componentRed: 249.0/255.0, green: 228.0/255.0, blue: 127.0/255.0, alpha: 0.6)
        
        let activeLineStyle = CPTMutableLineStyle()
        activeLineStyle.lineColor = activeLineColor
        activeLineStyle.lineWidth = 2.0
        
        let mostActivePlot = CPTScatterPlot()
        mostActivePlot.identifier = "Active"
        mostActivePlot.areaFill = CPTFill(color: activeLineColor)
        mostActivePlot.areaBaseValue = min
        mostActivePlot.dataLineStyle = activeLineStyle
        
        return mostActivePlot
    }

    func createHeatmapLimitBands(colorNumber: [Double], time: [Double], yMin: Double, yMax: Double) -> [CPTLimitBand] {
        let color1 = CPTColor(componentRed: 74.0/255.0, green: 170.0/255.0, blue: 214.0/155.0, alpha: 0.8)
        let color2 = CPTColor(componentRed: 138.0/255.0, green: 188.0/255.0, blue: 209.0/255.0, alpha: 0.8)
        let color3 = CPTColor(componentRed: 148.0/255.0, green: 158.0/255.0, blue: 163.0/255.0, alpha: 0.8)
        let color4 = CPTColor(componentRed: 209.0/255.0, green: 148.0/255.0, blue: 158.0/255.0, alpha: 0.8)
        let color5 = CPTColor(componentRed: 209.0/255.0, green: 95.0/255.0, blue: 102.0/255.0, alpha: 0.8)
        let colors = [color1, color2, color3, color4, color5, color5]
        
        var startIndex: Int = 0
        var previousColor = colorNumber[0]
        var limitBands = [CPTLimitBand]()
        
        for var i = 1; i < colorNumber.count - 1; ++i {
            if colorNumber[i] != previousColor {
                let length = time[i] - time[Int(startIndex)]
                let range = CPTPlotRange(location: time[Int(startIndex)], length: length)
                let color = Int(colorNumber[i])
                
                let newBand = CPTLimitBand(range: range, fill: CPTFill(color: colors[color]))
                
                limitBands.append(newBand)
                
                startIndex = i
                previousColor = colorNumber[i]
            }
        }
        
        let length = time[colorNumber.count - 1] - time[Int(startIndex)]
        let range = CPTPlotRange(location: time[Int(startIndex)], length: length)
        let color = colorNumber[colorNumber.count - 1]
        
        let newBand = CPTLimitBand(range: range, fill: CPTFill(color: colors[Int(color)]))
        
        limitBands.append(newBand)
        
        return limitBands
    }
    
}