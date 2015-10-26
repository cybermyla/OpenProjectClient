//
//  WPDetailViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WPDetailViewController: UIViewController {
    
    @IBOutlet weak var labelSubject: UILabel!

    var workpackage: WorkPackage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let wp = workpackage {
            labelSubject.text = wp.subject
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
   
    @IBAction func editButtonTapped(sender: AnyObject) {
        let vc = UIStoryboard.wpEditViewController()
        vc?.workpackage = self.workpackage
        let nav = UINavigationController(rootViewController: vc!)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
