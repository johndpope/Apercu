//
//  CompareCell.swift
//  Apercu
//
//  Created by David Lantrip on 12/25/15.
//  Copyright © 2015 Apercu. All rights reserved.
//

import Foundation
import UIKit

class CompareCell: UIKit.UITableViewCell {
    
    @IBOutlet var colorView: UIView!
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    override func awakeFromNib() {
        
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let backgroundColor = colorView.backgroundColor
        super.setHighlighted(hidden, animated: animated)
        
        if backgroundColor != UIColor.whiteColor() {
            colorView.backgroundColor = backgroundColor
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        let backgroundColor = colorView.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if backgroundColor != UIColor.whiteColor() {
            colorView.backgroundColor = backgroundColor
        }
    }
    
}
