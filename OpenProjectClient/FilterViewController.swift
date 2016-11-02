//
//  FilterViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 31/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        instanceId = defaults.value(forKey: "InstanceId") as! String!
        projectId = defaults.value(forKey: "ProjectId") as! NSNumber!
        print("InstanceId: \(instanceId), projectId: \(projectId)")
        getFilters()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func getFilters() {
        
        let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@", argumentArray: [instanceId, projectId])
        filters = WPFilter.mr_findAll(with: predicate) as! [WPFilter]
        if filters.count == 0 {
            createDefaultFilter()
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddFilterSegue" {
            if let vc = segue.destination as? FilterAddEditViewController {
       
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
        let filter = filters[(indexPath as NSIndexPath).row] as WPFilter
        cell?.textLabel?.text = filter.name!
        if filter.selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell!;
    }
    
    func createDefaultFilter() {
        let filter = WPFilter.mr_createEntity() as WPFilter
        filter.instanceId = instanceId
        filter.projectId = Int32(projectId)
        filter.name = "All"
        filter.selected = true
        filter.priorities = Priority.getAllPriorityIds(projectId, instanceId: instanceId) as NSObject?
        filter.statuses = Status.getAllStatusIds(projectId, instanceId: instanceId) as NSObject?
        filter.types = Type.getAllTypeIds(projectId, instanceId: instanceId) as NSObject?
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    
}
