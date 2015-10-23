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
    
    let workpackages: [String] = ["Mama", "Tata", "Evicka", "Klaudinka", "Mama", "Tata", "Evicka", "Klaudinka", "Mama", "Tata", "Evicka", "Klaudinka", "Mama", "Tata", "Evicka", "Klaudinka"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Work Packages"
        
        addFiltersButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func menuTapped(sender: AnyObject) {
        delegate?.toggleLeftPanel!()
    }
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workpackages.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkpackageCell") as UITableViewCell!
        cell.textLabel?.text = workpackages[indexPath.row]
        return cell;
    }

    //add filters button

    func addFiltersButton() {
        var toolbarButtons: [UIBarButtonItem] = []
        
        let filtersButton = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "filterTapped")
        
        toolbarButtons.append(filtersButton)
        
        let toolbar = UIToolbar()
        toolbar.frame = CGRectMake(0, self.view.frame.size.height - 46, self.view.frame.size.width, 46)
        toolbar.sizeToFit()
        toolbar.setItems(toolbarButtons, animated: true)
        self.view.addSubview(toolbar)
    }
    
    func filterTapped() {
        let vc = UIStoryboard.filtersViewController()
        delegate?.collapseSidePanels!()
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
    @IBAction func addWpTapped(sender: AnyObject) {
        let vc = UIStoryboard.newWorkpackageViewController()
        
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
}
