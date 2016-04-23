//
//  AlertView.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 17/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import UIKit

//Helper method to create and AlertView
func createAlert(viewController: UIViewController, message: String) {
    let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .Alert)
    
    let dismissButton = UIAlertAction(title: "Dismiss", style: .Default) { (action) -> Void in
        viewController.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    alert.addAction(dismissButton)
    viewController.presentViewController(alert, animated: true, completion: nil)
}