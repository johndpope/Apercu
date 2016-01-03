//
//  ApercuPlot.swift
//  Apercu
//
//  Created by David Lantrip on 1/3/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import CorePlot

class ApercuPlot {
    // Scatter plot, data and add apercu set data
    
    var plot: CPTScatterPlot!
    var data: [[CPTScatterPlotField: Double]]
    
    init(plot: CPTScatterPlot, data: [[CPTScatterPlotField: Double]]) {
        self.plot = plot
        self.data = data
    }
    
    func dataCount() -> UInt {
        return UInt(data.count)
    }
}