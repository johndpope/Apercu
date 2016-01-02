//
//  GraphHeatmap.swift
//  Apercu
//
//  Created by David Lantrip on 1/1/16.
//  Copyright © 2016 Apercu. All rights reserved.
//

import Foundation
import Accelerate

class GraphHeatmap {
    
    func heatmapPlotData(bpm: [Double], min: Double, max: Double, completion: (colorNumber: [Double]) -> Void) {
        var heatmapVector = [Double](count: bpm.count, repeatedValue: 0.0)
        var heatmapFloor = [Double](count: bpm.count, repeatedValue: 0.0)
        var heatmapCount = Int32(heatmapVector.count)
        
        var minNegated = min * -1.0
        let range = max - min
        var multiplier = 5 / range
        
        vDSP_vsaddD(bpm, 1, &minNegated, &heatmapVector, 1, vDSP_Length(bpm.count))
        vDSP_vsmulD(heatmapVector, 1, &multiplier, &heatmapVector, 1, vDSP_Length(heatmapVector.count))
        vvfloor(&heatmapFloor, &heatmapVector, &heatmapCount)
        
        completion(colorNumber: heatmapVector)
    }

}