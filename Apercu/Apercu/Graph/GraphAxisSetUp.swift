//
//  GraphView.swift
//  Apercu
//
//  Created by David Lantrip on 12/29/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit
import CorePlot

class GraphAxisSetUp {
    
    func initialSetup(axisSet: CPTXYAxisSet, duration: Double, min: Double) {
        
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor.whiteColor()
        lineStyle.lineWidth = 1.0
        
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineColor = CPTColor.whiteColor()
        axisLineStyle.lineWidth = 1.5
        
        let gridLineStyle = CPTMutableLineStyle()
        gridLineStyle.lineColor = CPTColor.init(componentRed: 1, green: 1, blue: 1, alpha: 1)
        gridLineStyle.dashPattern = [5, 5]
        gridLineStyle.lineWidth = 0.7
        
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.whiteColor()
        
        let xAxisLabelFormatter = GraphAxisNumberFormatter()
        let yAxisLabelFormatter = NSNumberFormatter()
        yAxisLabelFormatter.generatesDecimalNumbers = false
        
        updateLabelingPolicy(duration, axisSet: axisSet)
        axisSet.xAxis?.minorTicksPerInterval = 0
        axisSet.xAxis?.majorTickLineStyle = lineStyle
        axisSet.xAxis?.minorTickLineStyle = lineStyle
        axisSet.xAxis?.axisLineStyle = lineStyle
        axisSet.xAxis?.majorGridLineStyle = gridLineStyle
        axisSet.xAxis?.minorTickLength = 5.0
        axisSet.xAxis?.majorTickLength = 7.0
        axisSet.xAxis?.labelOffset = 3.0
        axisSet.xAxis?.labelingPolicy = .FixedInterval
        axisSet.xAxis?.labelTextStyle = axisTextStyle
        axisSet.xAxis?.labelFormatter = xAxisLabelFormatter
        
        axisSet.yAxis?.labelingOrigin = 0
        axisSet.yAxis?.majorIntervalLength = 20
        axisSet.yAxis?.minorTicksPerInterval = 3
        axisSet.yAxis?.majorTickLineStyle = lineStyle
        axisSet.yAxis?.minorTickLineStyle = lineStyle
        axisSet.yAxis?.axisLineStyle = axisLineStyle
        axisSet.yAxis?.minorTickLength = 7.0
        axisSet.yAxis?.majorTickLength = 12.0
        axisSet.yAxis?.labelOffset = 1.5
        axisSet.yAxis?.labelTextStyle = axisTextStyle
        axisSet.yAxis?.labelFormatter = yAxisLabelFormatter
        axisSet.yAxis?.coordinate = CPTCoordinate.Y
        
        axisSet.xAxis?.axisConstraints = CPTConstraints.constraintWithLowerOffset(0.0)
        axisSet.yAxis?.axisConstraints = CPTConstraints.constraintWithLowerOffset(0.0)
        axisSet.xAxis?.orthogonalPosition = min
    }
    
    func updateLabelingPolicy(duration: Double, axisSet: CPTXYAxisSet) {
        var interval: Int = 0;
        
        if duration > 60 * 60 {
            interval = 15 * 60
        } else if duration > 30 * 60 {
            interval = 10 * 60
        } else if duration > 10 * 60 {
            interval = 5 * 60
        } else {
            interval = 2 * 60
        }
        
        axisSet.xAxis?.majorIntervalLength = interval
    }

    
}