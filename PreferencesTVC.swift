//
//  PreferencesTVC.swift
//  ChildOnBoard
//
//  Created by J. HOWARD SMART on 5/31/16.
//  Copyright © 2016 J. HOWARD SMART. All rights reserved.
//

import UIKit

class PreferencesTVC: UITableViewController {
    var defaultRadius = 100
    var defaultCompanion = NSLocalizedString("Child", comment: "Child")
    
    var radii = [100, 200, 500]
    
    lazy var companionRows = [NSLocalizedString("Child", comment: "Child") : 0,
                              NSLocalizedString("Baby", comment: "Baby"): 1,
                              NSLocalizedString("Toddler", comment: "Toddler"): 2,
                              NSLocalizedString("Dog", comment: "Dog"): 3,
                              NSLocalizedString("Pet", comment: "Pet"): 4]
    
    lazy var companionTitles = [NSLocalizedString("Child", comment: "Child"),
                                NSLocalizedString("Baby", comment: "Baby"),
                                NSLocalizedString("Toddler", comment: "Toddler"),
                                NSLocalizedString("Dog", comment: "Dog"),
                                NSLocalizedString("Pet", comment: "Pet")]
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        setCheckmarkForRow(indexPath.row, inSection: indexPath.section)
    }
    
    func setCheckmarkForRow(selectedRow: Int, inSection section: Int){
        let numRows = tableView.numberOfRowsInSection(section)
        for row in 0..<numRows{
            let indexPath = NSIndexPath(forRow: row, inSection: section)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .None
            if row == selectedRow {
                cell?.accessoryType = .Checkmark
                if section == 0{
                    // Companion name section
                    defaultCompanion = cell?.textLabel?.text ?? defaultCompanion
                }else{
                    // Radius section
                    defaultRadius = radii[row]
                }
            }
        }
    }

    @IBAction func done(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(defaultCompanion, forKey: Constants.companionKey)
        defaults.setInteger(defaultRadius, forKey: Constants.radiusKey)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Green"))
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaultRadius = defaults.integerForKey(Constants.radiusKey)
        if defaultRadius == 0{
            defaultRadius = 100
            defaults.setInteger(100, forKey: Constants.radiusKey)
        }
        var row = 0
        switch defaultRadius {
        case 100:
            row = 0
        case 200:
            row = 1
        case 500:
            row = 2
        default:
            break
        }
        setCheckmarkForRow(row, inSection: 1)
        
        if let comp = defaults.stringForKey(Constants.companionKey){
            defaultCompanion = comp
        }else{
            defaultCompanion = "Child"
        }
        if let selectedCompanionRow = companionRows[defaultCompanion]{
            setCheckmarkForRow(selectedCompanionRow, inSection: 0)
        }
    }

}