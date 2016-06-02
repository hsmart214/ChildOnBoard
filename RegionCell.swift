//
//  RegionCell.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 6/1/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit

protocol RegionCellDelegate{
    func toggleMonitoringForRegion(_:COBCircularRegion)
}

class RegionCell: UITableViewCell {
    
    var delegate : RegionCellDelegate?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var checkMarkButton: UIButton!

    @IBAction func toggleNotify(sender: AnyObject) {
        if region != nil{
            delegate?.toggleMonitoringForRegion(region!)
        }
    }
    
    var region : COBCircularRegion? {
        didSet {
            nameLabel.text = region?.identifier
            let rad = region?.radius ?? 0.0
            radiusLabel.text = "\(Int(rad)) m"
            if region?.currentlyMonitored == nil{
                region?.currentlyMonitored = true
            }
            if let mon = region?.currentlyMonitored{
                if mon{
                    checkMarkButton.hidden = false
                }else{
                    checkMarkButton.hidden = true
                }
            }
        }
    }
}
