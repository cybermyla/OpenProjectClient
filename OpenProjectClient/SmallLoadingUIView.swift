//
//  SmallLoadingUIView.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 11/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class SmallLoadingUIView: UIView {

    private static var currentOverlay : UIView?
    
    static func show() {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow)
    }
    
    private static func show(_ overlayTarget : UIView) {
        // Clear it first in case it was already shown
        hide()
        
        
        // Create small view
        
        let xPosition = overlayTarget.frame.width / 8
        let smallView = UIView(frame: CGRect(x: xPosition, y: 20, width: 0, height: 0))
        smallView.backgroundColor = UIColor.red
        overlayTarget.addSubview(smallView)
        overlayTarget.bringSubview(toFront: smallView)
        
        // Create and animate the activity indicator
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicator.center = smallView.center
        indicator.startAnimating()
        smallView.addSubview(indicator)
        
        // Animate the overlay to show
        UIView.beginAnimations(nil, context: nil)
        UIView.commitAnimations()
        
        currentOverlay = smallView
    }
    
    static func hide() {
        if currentOverlay != nil {
            currentOverlay?.removeFromSuperview()
            currentOverlay =  nil
        }
    }
}
