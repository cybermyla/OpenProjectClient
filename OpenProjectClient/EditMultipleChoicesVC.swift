//
//  EditMultipleChoicesVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 29/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol EditMultipleChoicesVCDelegate {
    func multipleChoicesEditFinished()
}

class EditMultipleChoicesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var values: [(id: Int, name: String, href: String)] = []
    var delegate: EditMultipleChoicesVCDelegate?
    var schemaItem: WorkPackageFormSchema?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        self.title = schemaItem?.name
        
        //add an empty row in case attribute is optional
        if let required = schemaItem?.required {
            if !required {
                values.insert((Int(-1), "-", "empty"), at: 0)
            }
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override var prefersStatusBarHidden : Bool {
        get {
            return true
        }
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
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditMultipleChoicesTVC") as! EditMultipleChoicesTVC!
        let item = values[indexPath.row]
        cell?.accessoryType = .none
        cell?.selectionStyle = .none
        cell?.textLabel?.text = item.name
        if item.name == schemaItem?.value || item.id == -1 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //update newWorkPackage
        let v = values[indexPath.row]
        if v.id != -1 {
            schemaItem?.value = "\((v.name));\((v.href))"
        } else {
            schemaItem?.value_href = nil
            schemaItem?.value_title = nil
        }
        WorkPackageFormSchema.updateValue(schemaItem: schemaItem!)
        delegate?.multipleChoicesEditFinished()
    }
}
