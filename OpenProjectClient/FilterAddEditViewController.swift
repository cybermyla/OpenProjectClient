//
//  FilterAddEditViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class FilterAddEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var filterNameTextField: UITextField!
    
    var edit = false
    private var priorities: [Priority] = []
    private var types: [Type] = []
    private var statuses: [Status] = []
    
    private let defaults = UserDefaults.standard
    private var instanceId:String = ""
    private var projectId: NSNumber = -1
    
    private var sections: [Section] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        //multiple items selection
        self.tableView.allowsMultipleSelection = true
        
        self.title = edit ? "Edit Filter" : "Create Filter"

        setupGraphics()
        
        getData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func getData() {
        instanceId = defaults.value(forKey: "InstanceId") as! String!
        projectId = defaults.value(forKey: "ProjectId") as! NSNumber!
        priorities = Priority.getAllPriorities(projectId, instanceId: instanceId)
        types = Type.getAllTypes(projectId, instanceId: instanceId)
        statuses = Status.getAllStatuses(projectId, instanceId: instanceId)
        
        var typeFilterItems: [FilterItem] = []
        for item in types {
            typeFilterItems.append(FilterItem(name: item.name!, id: item.id, checked: false))
        }
        sections.append(Section(heading: "Types", items: typeFilterItems))
        
        var statusFilterItems: [FilterItem] = []
        for item in statuses {
            statusFilterItems.append(FilterItem(name: item.name!, id: item.id, checked: false))
        }
        sections.append(Section(heading: "Statuses", items: statusFilterItems))
        
        var priorityFilterItems: [FilterItem] = []
        for item in priorities {
            priorityFilterItems.append(FilterItem(name: item.name!, id: item.id as! Int32, checked: false))
        }
        sections.append(Section(heading: "Priorities", items: priorityFilterItems))
    }
    
    func setupGraphics() {
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        saveButton.backgroundColor = Colors.darkAzureOP.getUIColor()
        saveButton.tintColor = UIColor.white
        
        cancelButton.backgroundColor = Colors.lightAzureOP.getUIColor()
        cancelButton.tintColor = UIColor.white
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        filterNameTextField.leftView = paddingView;
        filterNameTextField.leftViewMode = UITextFieldViewMode.always
        filterNameTextField.placeholder = "Enter filter name"
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
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].heading
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterAddEditTableViewCell") as! FilterAddEditTableViewCell!
        let item = sections[indexPath.section].items[indexPath.row]
        cell?.textLabel?.text = item.name
        if item.checked {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        return cell!;
    }
    
    private struct Section {
        var heading: String
        var items: [FilterItem]
        
        init(heading: String, items: [FilterItem]) {
            self.heading = heading
            self.items = items
        }
    }
    
    private struct FilterItem {
        var name: String
        var id: Int32
        var checked: Bool
        
    }

}
