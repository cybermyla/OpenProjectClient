//
//  FilterDetailViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 19/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class FilterDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var filter: Filters? = nil
    
    var priorities: [Priority] = []
    var statuses: [Status] = []
    var types: [Type] = []
    
    let defaults = UserDefaults.standard
    var instanceId: String = ""
    var projectId: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //allow multiple selection
        self.tableView.allowsMultipleSelection = true
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        
        instanceId = defaults.value(forKey: "InstanceId") as! String
        projectId = defaults.value(forKey: "ProjectId") as! Int
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "\(filter!.rawValue) filter"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch filter! {
        case Filters.status:
            return statuses.count
        case Filters.type:
            return types.count
        case Filters.priority:
            return priorities.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FilterDetailTableViewCell") as! FilterDetailTableViewCell! {
            switch filter! {
            case Filters.priority:
                let filterValue = priorities[(indexPath as NSIndexPath).row] as Priority
                cell.textLabel?.text = filterValue.name
                if filterValue.show {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                break
            case Filters.status:
                let filterValue = statuses[(indexPath as NSIndexPath).row] as Status
                cell.textLabel?.text = filterValue.name
                if filterValue.show {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            case Filters.type:
                let filterValue = types[(indexPath as NSIndexPath).row] as Type
                cell.textLabel?.text = filterValue.name
                if filterValue.show {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        return cell;
        }
        return FilterDetailTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch filter! {
        case Filters.priority:
            let priority = priorities[indexPath.row] as Priority
            let updatedPriority = Priority.mr_findFirst(with: NSPredicate(format: "id == %@ AND projectId == %@", argumentArray: [priority.id!, priority.projectId!])) as Priority
            updatedPriority.show = true
            break
        case Filters.status:
            let status = statuses[indexPath.row] as Status
            let updatedStatus = Status.mr_findFirst(with: NSPredicate(format: "id == \(status.id) AND projectId == \(status.projectId)")) as Status
            updatedStatus.show = true
            break
        case Filters.type:
            let type = types[indexPath.row] as Type
            let updatedType = Type.mr_findFirst(with: NSPredicate(format: "id == \(type.id) AND projectId == \(type.projectId)")) as Type
            updatedType.show = true
            break
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch filter! {
        case Filters.priority:
            let priority = priorities[indexPath.row] as Priority
            let updatedPriority = Priority.mr_findFirst(with: NSPredicate(format: "id == %@ AND projectId == %@", argumentArray: [priority.id!, priority.projectId!])) as Priority
            updatedPriority.show = false
            break
        case Filters.status:
            let status = statuses[indexPath.row] as Status
            let updatedStatus = Status.mr_findFirst(with: NSPredicate(format: "id == \(status.id) AND projectId == \(status.projectId)")) as Status
            updatedStatus.show = false
            break
        case Filters.type:
            let type = types[indexPath.row] as Type
            let updatedType = Type.mr_findFirst(with: NSPredicate(format: "id == \(type.id) AND projectId == \(type.projectId)")) as Type
            updatedType.show = false
            break
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func getData() {
        switch filter! {
        case Filters.priority:
            getPriorities()
            break
        case Filters.status:
            getStatuses()
            break
        case Filters.type:
            getTypes()
            break
        }
    }
    
    func getPriorities() {
        getPrioritiesFromDB()
    }
    
    func getTypes() {
        getTypesFromDB()
    }
    
    func getStatuses() {
        getStatusesFromDB()
    }
    
    func getPrioritiesFromDB() {
        self.priorities = Priority.mr_findAllSorted(by: "position", ascending: true, with: NSPredicate(format: "instanceId = %i AND projectId = %i AND isActive == true", argumentArray: [instanceId, projectId])) as! [Priority]
        self.tableView.reloadData()
    }
    
    func getTypesFromDB() {
        self.types = Type.mr_findAllSorted(by: "position", ascending: true, with: NSPredicate(format: "instanceId = %i AND projectId = %i", argumentArray: [instanceId, projectId])) as! [Type]
        self.tableView.reloadData()
    }
    
    func getStatusesFromDB() {
        self.statuses = Status.mr_findAllSorted(by: "position", ascending: true, with: NSPredicate(format: "instanceId = %i AND projectId = %i", argumentArray: [instanceId, projectId])) as! [Status]
        self.tableView.reloadData()
    }
}
