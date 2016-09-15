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
    
    @IBOutlet weak var redundancySwitch: UISwitch!
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setCheckmarkForRow((indexPath as NSIndexPath).row, inSection: (indexPath as NSIndexPath).section)
    }
    
    func setCheckmarkForRow(_ selectedRow: Int, inSection section: Int){
        let numRows = tableView.numberOfRows(inSection: section)
        for row in 0..<numRows{
            let indexPath = IndexPath(row: row, section: section)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
            if row == selectedRow {
                cell?.accessoryType = .checkmark
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

    @IBAction func done(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        defaults.set(defaultCompanion, forKey: Constants.companionKey)
        defaults.set(defaultRadius, forKey: Constants.radiusKey)
        defaults.set(redundancySwitch.isOn, forKey: Constants.redundantNoticePreferenceKey)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "Green"))
        let defaults = UserDefaults.standard
        
        defaultRadius = defaults.integer(forKey: Constants.radiusKey)
        if defaultRadius == 0{
            defaultRadius = 100
            defaults.set(100, forKey: Constants.radiusKey)
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
        
        if let comp = defaults.string(forKey: Constants.companionKey){
            defaultCompanion = comp
        }else{
            defaultCompanion = "Child"
        }
        if let selectedCompanionRow = companionRows[defaultCompanion]{
            setCheckmarkForRow(selectedCompanionRow, inSection: 0)
        }
        redundancySwitch.setOn(defaults.bool(forKey: Constants.redundantNoticePreferenceKey), animated: true)
    }

}
