//
//  CenterViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: ContainerViewControllerDelegate?
    var project: Project?
    var workpackages: [WorkPackage] = []
    var instanceId: String?
    var projectId: NSNumber?
    let timeElapsedLimit = 180.0

    @IBOutlet weak var tableViewWorkPackages: UITableView!
    
    @IBOutlet weak var filterBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var addWPButton: UIBarButtonItem!
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    let defaults = UserDefaults.standard
    
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
        if segue.identifier == "SegueFilters" {

        }
    }

    
    @IBAction func menuTapped(_ sender: AnyObject) {
        delegate?.toggleLeftPanel!()
    }
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workpackages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkpackageCell") as! WorkPackagesTableViewCell!
        let wp = workpackages[(indexPath as NSIndexPath).row] as WorkPackage
        cell?.labelSubject.lineBreakMode = .byWordWrapping
        cell?.labelSubject.numberOfLines = 2
        cell?.labelSubject.text = wp.subject
        cell?.labelDescription.font = UIFont.italicSystemFont(ofSize: 12)
        cell?.labelDescription.text = "Status: \(wp.statusTitle!), Priority: \(wp.priorityTitle!), Type: \(wp.typeTitle!)"
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.wpDetailViewController()
        vc?.workpackage = workpackages[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(vc!, animated: true)
        
        tableViewWorkPackages.deselectRow(at: indexPath, animated: false)
    }
    
    //button add    
    @IBAction func buttonAddTapped(_ sender: AnyObject) {
        let vc = UIStoryboard.wpEditViewController()
        let navCon = UINavigationController(rootViewController: vc!)
        self.present(navCon, animated: true, completion: nil)
    }

    //filters button
    @IBAction func filterButtonTapped(_ sender: AnyObject) {

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
    
    func getWorkPackages(_ projectId: NSNumber, instanceId: String, refresh: Bool) {
        
        var timeElapsed: Double?
        
        if let lastUpdate = defaults.value(forKey: "WorkPackageLastUpdate") as? Date {
            timeElapsed = Date().timeIntervalSince(lastUpdate)
        }
        
        if timeElapsed == nil || timeElapsed! > timeElapsedLimit {
            getWorkPackagesFromServer(projectId, instanceId: instanceId, refresh: refresh)
        } else {
            self.workpackages = WorkPackage.getWorkPackages()
            self.tableViewWorkPackages.reloadData()
        }
        
    }
    
    func getWorkPackages(_ projectId: NSNumber, instanceId: String) {
        getWorkPackages(projectId, instanceId: instanceId, refresh: false)
    }
    
    func getWorkPackagesFromServer(_ projectId: NSNumber, instanceId: String, refresh: Bool) {
        if refresh {
            
        } else {
            LoadingUIView.show()
        }
        OpenProjectAPI.sharedInstance.getWorkPackagesByProjectId(projectId, instanceId: instanceId, onCompletion: {(responseObject:[WorkPackage]?, error:NSError?) in
            if let issue = error {
                print(issue.description)
                if refresh {
                    self.refreshControl?.endRefreshing()
                } else {
                    LoadingUIView.hide()
                }
            } else {
                if let _ = responseObject {
                    self.workpackages = WorkPackage.getWorkPackages()
                    if refresh {
                        self.refreshControl?.endRefreshing()
                    } else {
                        LoadingUIView.hide()
                    }
                    self.defaults.set(Date(), forKey: "WorkPackageLastUpdate")
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
                getWorkPackages(projectId, instanceId: instanceId, refresh: true)
            }
        }
    }
}
