//
//  CategoryCell.swift
//  Apercu
//
//  Created by David Lantrip on 12/26/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit

class CategoryCell: UIKit.UITableViewCell {
    
    @IBOutlet var label: UILabel!
    @IBOutlet var colorView: UIView!
    
    override func awakeFromNib() {
        
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let backgroundColor = colorView.backgroundColor
        super.setHighlighted(hidden, animated: animated)
        
        if backgroundColor != UIColor.clearColor() {
            colorView.backgroundColor = backgroundColor
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        let backgroundColor = colorView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if backgroundColor != UIColor.clearColor() {
            colorView.backgroundColor = backgroundColor
        }
    }
    
}