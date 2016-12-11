//
//  CenterViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewWorkPackageVCDelegate {
    
    var delegate: ContainerViewControllerDelegate?
    var project: Project?
    var workpackages: [WorkPackage] = []
    
    let defaults = UserDefaults.standard
    var instanceId: String?
    var projectId: NSNumber?
    
    var offset = 1
    var pageSize = 100
    
    let timeElapsedLimit = 180.0

    @IBOutlet weak var tableViewWorkPackages: UITableView!
    
    @IBOutlet weak var filterBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var addWPButton: UIBarButtonItem!
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    
    
    let filterLabel = UILabel(frame: CGRect.zero)
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Work Packages"
        setFilterLabelInToolbar()
        setNeedsStatusBarAppearanceUpdate()
        addRefresh()
        
        //disable filter and add button in case project is not selected
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let instanceId = defaults.value(forKey: "InstanceId") as? String {
            if let projectId = defaults.value(forKey: "ProjectId") as? NSNumber {
                getWorkPackages(projectId, instanceId: instanceId)
                self.updateFilterLableInToolbar(projectId, instanceId: instanceId)
            } else {
                showNoProjectAlert()
            }
        } else {
            ///show alert notifying that there is no instance selected. consider showing this alert just once after application start
            showNoInstanceAlert()
        }
        setButtons()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    @IBAction func menuTapped(_ sender: AnyObject) {
        delegate?.toggleLeftPanel!()
    }
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numOfSections = 1
        if workpackages.count == 0 {
            numOfSections = 0
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableViewWorkPackages.bounds.size.width, height: self.tableViewWorkPackages.bounds.size.height))
            noDataLabel.text = "No Workpackages"
            noDataLabel.textColor = Colors.darkAzureOP.getUIColor()
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableViewWorkPackages.backgroundView = noDataLabel
            self.tableViewWorkPackages.separatorStyle = .none
        } else {
            self.tableViewWorkPackages.backgroundView = nil
            self.tableViewWorkPackages.separatorStyle = .singleLine
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workpackages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkpackageCell") as! WorkPackagesTableViewCell!
        let wp = workpackages[(indexPath as NSIndexPath).row] as WorkPackage
        cell?.labelSubject.lineBreakMode = .byWordWrapping
        cell?.labelSubject.numberOfLines = 2
        if let subject = wp.subject {
            cell?.labelSubject.text = "#\(wp.id) \(subject)"
        }
        cell?.labelDescription.font = UIFont.italicSystemFont(ofSize: 12)
        cell?.labelDescription.text = "Status: \(wp.statusTitle!), Priority: \(wp.priorityTitle!), Type: \(wp.typeTitle!)"
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.cellForRow(at: indexPath) as! WorkPackagesTableViewCell
        //cell.labelSubject.textColor = UIColor.white
        let vc = UIStoryboard.wpDetailViewController()
        vc?.workpackage = workpackages[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(vc!, animated: true)
        tableViewWorkPackages.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let maxWpTotal = offset * pageSize
        if indexPath.row == maxWpTotal - 1 {
            if let instanceId = defaults.value(forKey: "InstanceId") as? String {
                if let projectId = defaults.value(forKey: "ProjectId") as? NSNumber {
                    if workpackages.count == maxWpTotal {
                        getWorkPackagesFromServer(projectId, instanceId: instanceId, getType: .loadMore)
                    }
                }
            }
        }
    }
    
    //button add    
    @IBAction func buttonAddTapped(_ sender: AnyObject) {
        let vc = UIStoryboard.wpEditViewController()
        let navCon = UINavigationController(rootViewController: vc!)
        self.present(navCon, animated: true, completion: nil)
    }
    
    func setButtons() {
        if let _ = defaults.value(forKey: "ProjectId") as? NSNumber {
            filterButton.isEnabled = true
            addWPButton.isEnabled = true
        } else {
            filterButton.isEnabled = false
            addWPButton.isEnabled = false
        }
    }
    
    func getWorkPackages(_ projectId: NSNumber, instanceId: String, getType: GetWorkpackageType) {
        
        var timeElapsed: Double?
        
        if let lastUpdate = defaults.value(forKey: "WorkPackageLastUpdate") as? Date {
            timeElapsed = Date().timeIntervalSince(lastUpdate)
        }
        
        if timeElapsed == nil || timeElapsed! > timeElapsedLimit {
            getWorkPackagesFromServer(projectId, instanceId: instanceId, getType: getType)
        } else {
            self.workpackages = WorkPackage.getWorkPackages(projectId: projectId, instanceId: instanceId)
            self.tableViewWorkPackages.reloadData()
        }
        
    }
    
    func getWorkPackages(_ projectId: NSNumber, instanceId: String) {
        getWorkPackages(projectId, instanceId: instanceId, getType: .initial)
    }
    
    func getWorkPackagesFromServer(_ projectId: NSNumber, instanceId: String, getType: GetWorkpackageType) {
        var truncate = true
        switch getType {
        case .initial:
            offset = 1
            LoadingUIView.show()
            break
        case .refresh:
            offset = 1
            break
        case .loadMore:
            truncate = false
            offset = offset + 1
            SmallLoadingUIView.show()
            break
        }

        OpenProjectAPI.sharedInstance.getWorkPackagesByProjectId(projectId, offset: offset, pageSize: pageSize, truncate: truncate, instanceId: instanceId, onCompletion: {(responseObject:[WorkPackage]?, error:NSError?) in
            if let issue = error {
                print(issue.description)
                switch getType {
                case .initial:
                    LoadingUIView.hide()
                    break
                case .refresh:
                    self.refreshControl?.endRefreshing()
                    break
                case .loadMore:
                    self.offset = self.offset - 1
                    SmallLoadingUIView.hide()
                    break
                }
            } else {
                if let _ = responseObject {
                    self.workpackages = WorkPackage.getWorkPackages(projectId: projectId, instanceId: instanceId)
                    
                    switch getType {
                    case .initial:
                        LoadingUIView.hide()
                        self.defaults.set(Date(), forKey: "WorkPackageLastUpdate")
                        break
                    case .refresh:
                        self.refreshControl?.endRefreshing()
                        self.defaults.set(Date(), forKey: "WorkPackageLastUpdate")
                        break
                    case .loadMore:
                        SmallLoadingUIView.hide()
                        break
                    }
                    
                    self.tableViewWorkPackages.reloadData()
                }
            }
        })
    }
    
    func showNoInstanceAlert() {
        let alertController = UIAlertController(title: "ERROR", message: "No instance is defined\nGo to settings and setup new instance", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch (action.style) {
            case .default:
                self.dismiss(animated: true, completion: nil)
                break
            default:
                break
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showNoProjectAlert() {
        let alertController = UIAlertController(title: "ERROR", message: "No project has been selected\nGo to settings and select a project", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch (action.style) {
            case .default:
                self.dismiss(animated: true, completion: nil)
                break
            default:
                break
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setFilterLabelInToolbar() {
        filterLabel.backgroundColor = UIColor.clear
        filterLabel.textAlignment = .left
        filterLabel.textColor = UIColor.white
        filterLabel.adjustsFontSizeToFitWidth = true
        filterBarButtonItem.customView = filterLabel
    }
    
    func updateFilterLableInToolbar(_ projectId: NSNumber, instanceId: String) {
        filterLabel.text = WPFilter.getFilterOneLineDescription(projectId, instanceId: instanceId)
        filterLabel.sizeToFit()
    }
    
    //tableview refresh functionality
    func addRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(refresh), for: UIControlEvents.valueChanged)
        self.tableViewWorkPackages.addSubview(refreshControl)
    }
    
    func refresh() {
        if let instanceId = defaults.value(forKey: "InstanceId") as? String {
            if let projectId = defaults.value(forKey: "ProjectId") as? NSNumber {
                defaults.set(nil, forKey: "WorkPackageLastUpdate")
                getWorkPackages(projectId, instanceId: instanceId, getType: .refresh)
            }
        }
    }
    
    func workpackageCreationUpdateFinished(workPackageId: Int32) {
        refresh()
    }
}
