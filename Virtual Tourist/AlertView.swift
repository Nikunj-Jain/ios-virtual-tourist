//
//  AlertView.swift
//  Virtual Tourist
//
//  Created by Nikunj Jain on 17/04/16.
//  Copyright © 2016 Nikunj Jain. All rights reserved.
//

import UIKit

func createAlert(viewController: UIViewController, message: String) {
    let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .Alert)
    
    let dismissButton = UIAlertAction(title: "Dismiss", style: .Default) { (action) -> Void in
        alert.dismissViewControllerAnimated(true, completion: nil)
    }
    
    alert.addAction(dismissButton)
    viewController.presentViewController(alert, animated: true, completion: nil)
}