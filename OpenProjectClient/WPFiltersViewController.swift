//
//  WPFiltersViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 21/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WPFiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let filterCategories = ["Status", "Type"]
    
    @IBOutlet weak var filtersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        filtersTableView.reloadData()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        //UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneTapped(_ sender: AnyObject) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCategories.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell") as! FilterTableViewCell!
        let filterCategory = filterCategories[(indexPath as NSIndexPath).row] as String
        cell?.textLabel?.text = filterCategory
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let vc = UIStoryboard.wpDetailViewController()

        //self.navigationController?.pushViewController(vc!, animated: true)
        
        filtersTableView.deselectRow(at: indexPath, animated: false)
    }

}
