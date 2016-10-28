//
//  WPFiltersViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 21/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WPFiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let filterCategories = [Filters.status, Filters.type, Filters.priority]
    
    @IBOutlet weak var filtersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //removes empty rows in UITableView
        filtersTableView.tableFooterView = UIView()
        self.title = "Filters"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.automaticallyAdjustsScrollViewInsets = false
        filtersTableView.reloadData()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueFilterDetail" {
            if let destination = segue.destination as? FilterDetailViewController {
                destination.filter = filterCategories[(filtersTableView.indexPathForSelectedRow?.row)!]
            }
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
 
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCategories.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell") as! FilterTableViewCell!
        let filterCategory = filterCategories[(indexPath as NSIndexPath).row] as Filters
        cell?.textLabel?.text = filterCategory.rawValue
        return cell!;
    }
}
