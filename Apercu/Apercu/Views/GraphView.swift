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

class GraphView: UIView, CPTPlotDataSource, CPTPlotSpaceDelegate {
    
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    
    var graph: CPTXYGraph!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        setupGraph()
    }
    
    func setupGraph() {
        graph = CPTXYGraph.init(frame: self.bounds)
        graph.applyTheme(CPTTheme.init(named: kCPTPlainWhiteTheme))
        graphHostingView.hostedGraph = graph
        
        var plotSpace = graph.defaultPlotSpace
        plotSpace?.allowsUserInteraction = true
        plotSpace!.delegate = self
        
        
    }
    
    
    
    func setupAxisSet() {
        let lineStyle = CPTMutableLineStyle.init()
        lineStyle.lineColor = CPTColor.whiteColor()
        lineStyle.lineWidth = 1.0
        
        let axisLineStyle = CPTMutableLineStyle.init()
        axisLineStyle.lineColor = CPTColor.whiteColor()
        axisLineStyle.lineWidth = 1.5
        
        let gridLineStyle = CPTMutableLineStyle.init()
        gridLineStyle.lineColor = CPTColor.init(componentRed: 1, green: 1, blue: 1, alpha: 1)
        gridLineStyle.dashPattern = [5, 5]
        gridLineStyle.lineWidth = 0.7
        
        let axisSet: CPTXYAxisSet = graph.axisSet
        axisSet.
        
    }
    
}