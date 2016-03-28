//
//  ColorPicker.swift
//  Apercu
//
//  Created by David Lantrip on 12/20/15.
//  Copyright © 2015 David Lantrip. All rights reserved.
//

import Foundation
import UIKit
import Color_Picker_for_iOS

protocol ColorPickerDelegate {
    func didAddNewColor();
}

class ColorPickerViewController: UIViewController {
    
    @IBOutlet weak var colorSlider: HRBrightnessSlider!
    @IBOutlet weak var colorInfo: HRColorInfoView!
    @IBOutlet weak var colorMap: HRColorMapView!
    @IBOutlet var colorPicker: HRColorPickerView!
    
    var categoryNumber: NSNumber!
    var isNewColor = 0
    var delegate: ColorPickerDelegate!
    var color: UIColor!
    
    override func viewDidLoad() {
        title = "Pick a Color"
        
        colorPicker.colorInfoView = colorInfo
        
        if isNewColor == 1 {
            colorPicker.color = self.view.tintColor
        } else {
            colorPicker.color = color
        }
        
        colorMap.tileSize = 5
        colorMap.saturationUpperLimit = 1
        
        colorPicker.colorMapView = colorMap
        colorPicker.brightnessSlider = colorSlider
        colorSlider.brightnessLowerLimit = 0
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WorkoutDetailViewController.screenRotated(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        colorPicker.addTarget(self, action: #selector(ColorPickerViewController.colorUpdate(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func colorUpdate(sender: AnyObject!) {
        
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        
        if isNewColor == 1 {
            CoreDataHelper().addNewCategory(colorPicker.color)
            delegate.didAddNewColor()
        } else {
            CoreDataHelper().updateCategoryColor(categoryNumber, color: colorPicker.color)
        }
        
        navigationController?.popViewControllerAnimated(true)
        if delegate != nil {
//            delegate.didUseColorPicker(self)
        }
        
    }
    
    
    func screenRotated(sender: AnyObject) {
        colorMap.setNeedsDisplay()
        view.setNeedsDisplay()
    }
    
}

