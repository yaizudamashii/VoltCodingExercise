//
//  AppAlerts.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit

class AppAlerts: NSObject {
    class func debugErrorDisplayAlertWithDissmissAction(errorDesc : String, dismissHandler : ((Void) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title:AppError, message: errorDesc, preferredStyle: UIAlertControllerStyle.Alert)
        let dismissActionHandler = { (action:UIAlertAction!) -> Void in
            dismissHandler?()
        }
        let dismiss = UIAlertAction(title:AppDismiss, style: UIAlertActionStyle.Default, handler:dismissActionHandler)
        alert.addAction(dismiss)
        return alert
    }
}
