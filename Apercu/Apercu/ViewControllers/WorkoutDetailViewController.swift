//
//  WorkoutDetailViewController.swift
//  Apercu
//
//  Created by David Lantrip on 12/29/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit
import CorePlot

class WorkoutDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CPTPlotSpaceDelegate, CPTPlotDataSource {
    
    var currentWorkout: ApercuWorkout!
    
    @IBOutlet var hostView: CPTGraphHostingView!
    @IBOutlet var scrollView: CustomScrollView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var colorView: UIView!
    @IBOutlet private var segment: UISegmentedControl!
    @IBOutlet private var mostActiveSwitch: UISwitch!
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var colorLabel: UILabel!
    
    @IBOutlet private var colorButton: UIButton!
    @IBOutlet private var categorizeButton: UIButton!
    @IBOutlet private var optionsButton: UIButton!
    
    @IBOutlet private var tableViewHeight: NSLayoutConstraint!
    @IBOutlet private var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet private var graphConstraintBottom: NSLayoutConstraint!
    @IBOutlet private var graphConstraintHeight: NSLayoutConstraint!
    @IBOutlet private var graphConstraintLeading: NSLayoutConstraint!
    @IBOutlet private var graphConstraintTrailing: NSLayoutConstraint!
    
    var plots = [String: ApercuPlot]()
    var heatmapPlots: [ApercuPlot]!
    var workoutStats: [String: AnyObject]!
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    var graph: CPTXYGraph!
    
    var min: Double!
    var plotMin: Double!
    var max: Double!
    var plotMax: Double!
    var duration: Double!
    var avg: Double!
    var bpm: [Double]!
    var time: [Double]!
    
    var backgroundColor = CPTColor(componentRed: 89.0/255.0, green: 87.0/255.0, blue: 84.0/255.0, alpha: 1.0)
    var goingToNewYAxis = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        tabBarController!.tabBar.hidden = true
        categorizeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        optionsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        segment.setEnabled(false, forSegmentAtIndex: 1)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        graph = CPTXYGraph(frame: self.view.bounds)
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.plotAreaFrame?.borderLineStyle = nil
        graph.plotAreaFrame?.masksToBorder = false
        graph.drawsAsynchronously = true
        graph.plotAreaFrame?.plotArea?.fill = CPTFill(color: backgroundColor)
        graph.backgroundColor = backgroundColor.cgColor
        
        hostView.hostedGraph = graph
        hostView.userInteractionEnabled = true
        hostView.allowPinchScaling = true
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.allowsMomentum = true
        
        let initialXrange = CPTPlotRange(location: 0, length: 10)
        plotSpace.xRange = initialXrange
        plotSpace.globalXRange = initialXrange
        plotSpace.delegate = self
        
        GraphAxisSetUp().initialSetup((self.graph.axisSet as? CPTXYAxisSet)!, duration: 60, min: 50)
        
        ProcessWorkout().heartRatePlotDate(currentWorkout.getStartDate()!, end: currentWorkout.getEndDate()!, includeRaw: true, statsCompleted: { (stats) -> Void in
            // Stats for graph completed (min, max, avg, duration)
            // update graph
            self.min = stats["min"] as! Double
            self.plotMin = self.min - 3.0
            self.max = stats["max"] as! Double
            self.plotMax = self.max + 3.0
            self.avg = stats["avg"] as! Double
            self.duration = stats["duration"] as! Double
            self.bpm = stats["bpm"] as! [Double]
            self.time = stats["time"] as! [Double]
            
            let scatterPlots = GraphPlotSetup().detailPlotSetup()
            let plotDataCreator = GraphDataSetup()
            
            self.plots["Main"] = ApercuPlot(plot: scatterPlots[0], data: plotDataCreator.createMainPlotData(self.bpm, time: self.time))
            self.plots["Average"] = ApercuPlot(plot: scatterPlots[1], data: plotDataCreator.createAveragePlotData(self.avg, duration: self.duration))
            self.plots["Top Fill"] = ApercuPlot(plot: scatterPlots[2], data: plotDataCreator.createTopFillPlotData(self.duration))
            self.plots["Bottom Fill"] = ApercuPlot(plot: scatterPlots[3], data: plotDataCreator.createBottomFillPlotData(self.duration))
            self.plots["Zero"] = ApercuPlot(plot: scatterPlots[4], data: plotDataCreator.createZeroLineData(self.duration))
            
            // show plots
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.addPlotsForNormalView()
                
                self.graph.reloadData()
                self.setFullXRange()
                self.goingToNewYAxis = true
                self.setFullYRange()
                self.goingToNewYAxis = false
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    GraphHeatmap().heatmapRawData(self.bpm, min: self.min, max: self.max, completion: { (colorNumber) -> Void in
                        
                        self.heatmapPlots = GraphPlotSetup().createHeatmapPlot(colorNumber, time: self.time, yMin: self.plotMin, yMax: self.plotMax)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.segment.setEnabled(true, forSegmentAtIndex: 1)
                        })
                    })
                })
            })
            
            
            }, completion: { (results) -> Void in
                // Stats for min and moderate time completed
                // update table view
                
                
        })
        
        
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let screenRect = UIScreen.mainScreen().bounds
        
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
            graphConstraintBottom.constant = 10
            graphConstraintLeading.constant = 20
            graphConstraintTrailing.constant = 20
            graphConstraintHeight.constant = 0.5 * screenRect.size.height
        } else {
            graphConstraintBottom.constant = 10
            graphConstraintLeading.constant = 30
            graphConstraintTrailing.constant = 30
            graphConstraintHeight.constant = 0.7 * screenRect.size.height
        }
        
    }
    
    // Mark - Graph Helpers
    
    func setFullXRange() {
        let xMin = 0.0
        let xMax = duration
        
        let xRange = CPTPlotRange(location: xMin, length: xMax)
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = xRange
        plotSpace.globalXRange = xRange
    }
    
    func setFullYRange() {
        let yMin = plotMin
        
        let yRangeToFitData = plotMax - plotMin
        let yRangeForMaxHr = IntensityThresholdSingleton.sharedInstance.maximumHeatRate - plotMin
        
        let yRange = CPTPlotRange(location: yMin, length: fmax(yRangeToFitData, yRangeForMaxHr))
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.yRange = yRange
        plotSpace.globalYRange = yRange
    }
    
    func addPlotsForNormalView() {
        let plotList: [CPTScatterPlot] = [(plots["Bottom Fill"]?.plot)!, (plots["Top Fill"]?.plot)!, (plots["Zero"]?.plot)!, (plots["Average"]?.plot)!, (plots["Main"]?.plot)!]
        
        for plot in plotList {
            plot.dataSource = self
            graph.addPlot(plot)
        }
    }
    
    // Mark: - Graph Delegates
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        let identifier = plot.identifier as! String
        
        if identifier == "Main" {
            return plots["Main"]!.dataCount()
        } else if identifier == "Average" {
            return plots["Average"]!.dataCount()
        } else if identifier == "Top Fill" {
            return plots["Top Fill"]!.dataCount()
        } else if identifier == "Bottom Fill" {
            return plots["Bottom Fill"]!.dataCount()
        } else if identifier == "Zero" {
            return plots["Zero"]!.dataCount()
        } else {
            // for heatmap plots
            return 4
        }
    }
    
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        let identifier = plot.identifier as! String
        
        var fieldCoord: CPTScatterPlotField
        
        fieldCoord = fieldEnum == 0 ? CPTScatterPlotField.X : CPTScatterPlotField.Y
        
        if identifier == "Main" {
            return plots["Main"]!.data[Int(idx)][fieldCoord]
        } else if identifier == "Average" {
            return plots["Average"]!.data[Int(idx)][fieldCoord]
        } else if identifier == "Top Fill" {
            return plots["Top Fill"]!.data[Int(idx)][fieldCoord]
        } else if identifier == "Bottom Fill" {
            return plots["Bottom Fill"]!.data[Int(idx)][fieldCoord]
        } else if identifier == "Zero Line" {
            return plots["Zero"]!.data[Int(idx)][fieldCoord]
        } else {
            // heatmap plots
            return 1
        }
    }
    
    func plotSpace(space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, forCoordinate coordinate: CPTCoordinate) -> CPTPlotRange? {
        var updatedRange: CPTPlotRange!
        
        switch coordinate {
        case CPTCoordinate.X:
            if newRange.location.isLessThan(NSNumber(double: 0.0)) {
                var mutableRangeCopy: CPTMutablePlotRange!
                mutableRangeCopy = newRange.mutableCopy() as! CPTMutablePlotRange
                mutableRangeCopy.location = NSNumber(double: 0.0)
                updatedRange = mutableRangeCopy
            } else {
                updatedRange = newRange
            }
        case CPTCoordinate.Y:
            if goingToNewYAxis {
                updatedRange = newRange
            } else {
                let plotSpace = space as! CPTXYPlotSpace
                updatedRange = plotSpace.yRange
            }
        default:
            break
        }
        
        return updatedRange
    }
    
    // Mark: - IBActions for Button Presses
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
    }
    
    @IBAction func activeSwitchChanged(sender: UISwitch) {
        
    }
    
    // Mark: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    
}