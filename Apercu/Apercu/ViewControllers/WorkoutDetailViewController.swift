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
import HealthKit

class WorkoutDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CPTPlotSpaceDelegate, CPTPlotDataSource, ActiveSliderChanged {
    
    var currentWorkout: ApercuWorkout!
    
    @IBOutlet var hostView: CPTGraphHostingView!
    @IBOutlet var scrollView: CustomScrollView!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var backgroundView: UIView!
    @IBOutlet private var colorView: UIView!
    @IBOutlet private var segment: UISegmentedControl!
    @IBOutlet private var mostActiveSwitch: UISwitch!
    @IBOutlet private var activeView: ActiveSlider!
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
    var limitBands: [CPTLimitBand]!
    var workoutStats: [String: AnyObject]!
    let defs = NSUserDefaults.init(suiteName: "group.com.apercu.apercu")
    var graph: CPTXYGraph!
    var axisSet: CPTXYAxisSet!
    
    var min: Double!
    var plotMin: Double!
    var max: Double!
    var plotMax: Double!
    var duration: Double!
    var avg: Double!
    var bpm: [Double]!
    var time: [Double]!
    var distance: Double!
    var calories: Double!
    var moderateIntensityTime: Double!
    var highIntensityTime: Double!
    
    var tableStrings: [NSAttributedString]!
    var tableValues: [NSAttributedString]?
    
    var backgroundColor = CPTColor(componentRed: 89.0/255.0, green: 87.0/255.0, blue: 84.0/255.0, alpha: 1.0)
    var alternateCellColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    var goingToNewYAxis = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        tabBarController!.tabBar.hidden = true
        categorizeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        optionsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        segment.setEnabled(false, forSegmentAtIndex: 1)
        activeView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 30.0
        tableView.rowHeight = UITableViewAutomaticDimension
        updateTableHeight()
        
        graph = CPTXYGraph(frame: self.view.bounds)
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))
        graph.plotAreaFrame?.borderLineStyle = nil
        graph.plotAreaFrame?.masksToBorder = false
        graph.drawsAsynchronously = true
        graph.plotAreaFrame?.plotArea?.fill = CPTFill(color: backgroundColor)
        graph.backgroundColor = backgroundColor.cgColor
        axisSet = graph.axisSet as? CPTXYAxisSet
        
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
        
        tableStrings = GraphTableStrings().allHeaderStrings()
        
        GraphAxisSetUp().initialSetup((self.graph.axisSet as? CPTXYAxisSet)!, duration: 60, min: 50)
        
        ProcessWorkout().heartRatePlotDate(currentWorkout.getStartDate()!, end: currentWorkout.getEndDate()!, includeRaw: true, statsCompleted: {
            (stats) -> Void in
            
            // Stats for graph completed (min, max, avg, duration)
            // update graph
            self.min = stats["min"] as! Double
            self.plotMin = self.min - 3.0
            self.max = stats["max"] as! Double
            self.plotMax =  self.max + 3.0
            self.avg = stats["avg"] as! Double
            self.duration = stats["duration"] as! Double
            self.bpm = stats["bpm"] as! [Double]
            self.time = stats["time"] as! [Double]
            
            let scatterPlots = GraphPlotSetup().detailPlotSetup()
            let plotDataCreator = GraphDataSetup()
            
            self.plots["Main"] = ApercuPlot(plot: scatterPlots[0], data: plotDataCreator.createMainPlotData(self.bpm, time: self.time))
            self.plots["Average"] = ApercuPlot(plot: scatterPlots[1], data: plotDataCreator.createAveragePlotData(self.avg, duration: self.duration))
            
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
                        
                        self.limitBands = GraphPlotSetup().createHeatmapLimitBands(colorNumber, time: self.time, yMin: self.plotMin, yMax: self.plotMax) as! [CPTLimitBand]
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.segment.setEnabled(true, forSegmentAtIndex: 1)
                        })
                    })
                })
            })
            
            
            }, completion: { (results) -> Void in
                self.moderateIntensityTime = results["mod"] as! Double
                self.highIntensityTime = results["high"] as! Double
                let duration = results["duration"] as! Double
                
                let milesUnit = HKUnit.mileUnit()
                self.distance = self.currentWorkout.healthKitWorkout?.totalDistance?.doubleValueForUnit(milesUnit)
                
                let caloriesUnit = HKUnit.kilocalorieUnit()
                self.calories = self.currentWorkout.healthKitWorkout?.totalEnergyBurned?.doubleValueForUnit(caloriesUnit)
                
                let description: Double = Double((self.currentWorkout.healthKitWorkout?.workoutActivityType.rawValue)!)
                
                let rawValues: [Double] = [duration, self.moderateIntensityTime, self.highIntensityTime, self.distance, self.calories, description]
                
                self.tableValues = GraphTableStrings().allValueStrings(rawValues)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.view.layoutIfNeeded()
                    self.updateTableHeight()

                    self.tableView.reloadData()
                    self.updateTableHeight()
                })
           
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
    
    // MARK: - Graph Helpers
    
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
        let yLengthMax = fmax(yRangeToFitData, yRangeForMaxHr)
        
        let yRange = CPTPlotRange(location: yMin, length: yLengthMax)
        plotMax = yMin + yLengthMax
        
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.yRange = yRange
        plotSpace.globalYRange = yRange
    }
    
    func addPlotsForNormalView() {
        addIntensityLimitBands()
        addMainPlots()
    }
    
    func addPlotsForHeatmap() {
        for band in limitBands {
            axisSet?.xAxis?.addBackgroundLimitBand(band)
        }
        addMainPlots()
    }
    
    func addMainPlots() {
        if let activePlot = plots["Active"]?.plot {
            activePlot.dataSource = self
            graph.addPlot(activePlot)
        }
        
        if let averagePlot = plots["Average"]?.plot  {
            averagePlot.dataSource = self
            graph.addPlot(averagePlot)
        }
        
        if let mainPlot = plots["Main"]?.plot {
            mainPlot.dataSource = self
            graph.addPlot(mainPlot)
        }
    }
    
    func addIntensityLimitBands() {
        let intensityThresholds = IntensityThresholdSingleton.sharedInstance
        
        let maxHighIntensity = intensityThresholds.maximumHeatRate * 0.9
        let highIntensityThreshold = intensityThresholds.highIntensityThreshold
        let moderateIntensityTreshold = intensityThresholds.moderateIntensityThreshold
        
        let modThresholdRange = CPTPlotRange(location: moderateIntensityTreshold, length: highIntensityThreshold - moderateIntensityTreshold)
        let highThresholdRange = CPTPlotRange(location: maxHighIntensity, length: -(maxHighIntensity - highIntensityThreshold))
        
        let modBand = CPTLimitBand(range: modThresholdRange, fill: CPTFill(color: CPTColor(componentRed: 250.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 0.35)))
        let highBand = CPTLimitBand(range: highThresholdRange, fill: CPTFill(color: CPTColor(componentRed: 250.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.6)))
        
        axisSet.yAxis?.addBackgroundLimitBand(modBand)
        axisSet.yAxis?.addBackgroundLimitBand(highBand)
    }
    
    func removeAllPlots() {
        if let activePlot = plots["Active"] {
            graph.removePlotWithIdentifier("Active")
            if activePlot.plot.graph != nil {
                graph.removePlotWithIdentifier("Active")
                graph.removePlot(activePlot.plot)
            }
        }
        
        for (_, element) in plots.enumerate() {
            if element.1.plot.graph != nil {
                graph.removePlot(element.1.plot)
            }
        }
        
        let axisSet = graph.axisSet as? CPTXYAxisSet
        axisSet?.yAxis?.removeAllBackgroundLimitBands()
        axisSet?.xAxis?.removeAllBackgroundLimitBands()
    }
    
    // MARK: - Graph Delegates
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        let identifier = plot.identifier as! String
        
        if identifier == "Main" {
            return plots["Main"]!.dataCount()
        } else if identifier == "Average" {
            return plots["Average"]!.dataCount()
        } else if identifier == "Active" {
            return plots["Active"]!.dataCount()
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
        } else if identifier == "Active" {
            return plots["Active"]!.data[Int(idx)][fieldCoord]
        } else {
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
    
    // MARK: - IBActions for Button Presses
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            // Normal Graph
            removeAllPlots()
            addPlotsForNormalView()
        } else {
            // Heatmap
            removeAllPlots()
            addPlotsForHeatmap()
        }
    }
    
    @IBAction func activeSwitchChanged(sender: UISwitch) {
        
    }
    
    // MARK: UITableView Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableValues == nil {
            return 1
        } else {
            return tableValues!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StatReuse", forIndexPath: indexPath) as! SingleLineStatCell
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = alternateCellColor
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        if tableValues == nil {
            cell.stringLabel.text = "Loading stats..."
            cell.valueLabel.text = ""
        } else {
            cell.stringLabel.attributedText = tableStrings[indexPath.row]
            cell.valueLabel.attributedText = tableValues![indexPath.row]
        }
        
        return cell
    }
    
    func updateTableHeight() {
        view.layoutIfNeeded()
        tableViewHeight.constant = tableView.contentSize.height
    }
    
    // MARK: Active Duration Changed

    func sliderChanged(activeDuration: Int) {
        if activeDuration != 0 {
            plots["Active"] = nil
            self.plots["Active"]?.plot = nil
            self.plots["Active"]?.data.removeAll()
            
            GraphMostActive().mostActivePeriod(bpm, times: time, duration: Double(activeDuration), completion: { (timeOne, timeTwo) -> Void in
                
                let activeData = GraphDataSetup().createMostActivePlotData(timeOne, end: timeTwo, max: self.plotMax, min: self.plotMin)
                let activePlot = GraphPlotSetup().createMostActivePlot(self.plotMin)
//                let activeApercuPlot = ApercuPlot(plot: activePlot, data: activeData)
                
               
                self.plots["Active"] = ApercuPlot(plot: activePlot, data: activeData)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.removeAllPlots()
                    
                    if self.segment.selectedSegmentIndex == 0 {
                        self.addPlotsForNormalView()
                    } else {
                        self.addPlotsForHeatmap()
                    }
                })
            })
        } else {
            
        }
    }
}