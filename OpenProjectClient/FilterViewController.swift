//
//  FilterViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 31/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FilterAddEditViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    var filters: [WPFilter] = []
    
    let defaults = UserDefaults.standard
    var instanceId: String = ""
    var projectId: NSNumber = -1
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addFilterButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        //color add filter button
        addFilterButton.backgroundColor = Colors.lightAzureOP.getUIColor()
        addFilterButton.tintColor = UIColor.white
        //set title
        self.title = "Filters"
        self.navigationItem.rightBarButtonItem = editButtonItem
        
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        instanceId = defaults.value(forKey: "InstanceId") as! String!
        projectId = defaults.value(forKey: "ProjectId") as! NSNumber!
        filters = WPFilter.getFilters(projectId, instanceId: instanceId)

        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddFilterSegue" {
            if let adpostVC = segue.destination as? FilterAddEditViewController {
                let popVC = adpostVC.popoverPresentationController
                popVC?.delegate = self
                adpostVC.delegate = self
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell") as! FilterTableViewCell!
        cell?.selectionStyle = .none
        let filter = filters[(indexPath as NSIndexPath).row] as WPFilter
        let labelArray = getLabels(str: filter.name!)
        cell?.labelType.attributedText = labelArray[0]
        cell?.labelStatus.attributedText = labelArray[1]
        cell?.labelPriority.attributedText = labelArray[2]
        if filter.selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        WPFilter.deselectAllFilters(projectId, instanceId: instanceId)
        WPFilter.selectFilter(filters[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        WPFilter.deselectFilter(filters[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.tableView.setEditing(editing, animated: animated)
        self.addFilterButton.isEnabled = false
        if editing == false {
            self.addFilterButton.isEnabled = true
            tableView.reloadData()
        }
    }
    
    // Override to support editing the table view.
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "EDIT", handler: {action ,index in
            let vc = UIStoryboard.filterAddEditViewController()
            
            let navControler: UINavigationController = UINavigationController(rootViewController: vc!)
            vc?.delegate = self
            vc?.editedFilter = self.filters[indexPath.row]
            self.present(navControler, animated: true, completion: nil)
        })
        edit.backgroundColor = Colors.darkAzureOP.getUIColor()
        
        let delete = UITableViewRowAction(style: .destructive, title: "DELETE", handler: {
            action, index in
            WPFilter.deleteWPFilter(filter: self.filters[indexPath.row])
            self.filters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        })
        delete.backgroundColor = UIColor.red
        return [delete, edit]
    }
    
    //FilterAddEditViewControllerDelegate 
    func filterEditFinished() {
        filters = WPFilter.getFilters(projectId, instanceId: instanceId)
        self.tableView.reloadData()
    }
    
    //UIPopoverPresentationControllerDelegate functions
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.fullScreen
    }
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    //misc
    func getLabels(str: String) -> [NSAttributedString] {
        let arr = str.components(separatedBy: ",")
        
        let typeString = createParametersLabel("Types", str: arr[0])
        let statusString = createParametersLabel("Statuses", str: arr[1])
        let priorityString = createParametersLabel("Priorities", str: arr[2])
        return [typeString,statusString,priorityString]
    }
    
    func createParametersLabel(_ name: String, str: String) -> NSAttributedString {
        let strRange = str.index(after: str.startIndex)..<str.index(before: str.endIndex)
        let substr = str.substring(with: strRange)
        if substr.characters.count > 0 {
            let arr = substr.components(separatedBy: ";")
            let string = "\(name): \(arr.joined(separator: ", "))"
            let nonBoldRange = NSRange(location: name.characters.count + 1, length: string.characters.count - name.characters.count - 1)
            let attString = attributedString(from: string, nonBoldRange: nonBoldRange)
            return attString
        } else {
            let string = "\(name): All"
            let nonBoldRange = NSRange(location: name.characters.count + 1, length: string.characters.count - name.characters.count - 1)
            return attributedString(from: string, nonBoldRange: nonBoldRange)
        }
    }
    
    func attributedString(from string: String, nonBoldRange: NSRange?) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: Colors.darkAzureOP.getUIColor()
        ]
        let nonBoldAttribute = [
            NSFontAttributeName: UIFont.italicSystemFont(ofSize: fontSize),
            ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }
}
