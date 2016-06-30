//
//  PhotosViewController.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit
import PureLayout

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView = UITableView(frame: self.view.bounds)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        let nibName = UINib(nibName: "PhotoTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "photoCell")
        self.tableView.estimatedRowHeight = self.view.frame.size.width
        self.tableView.autoPinEdgesToSuperviewEdges()
        
        FlickrService.sharedInstance.getRecentPublicPhotosWithCompletionHandler(1, completionHandler: {(photos : [Photo]?, error : NSError?) -> Void in
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            } else {
                let errorAlert : UIAlertController = AppAlerts.debugErrorDisplayAlertWithDissmissAction(error!.localizedDescription, dismissHandler : nil)
                dispatch_async(dispatch_get_main_queue(), {
                    if (self.presentedViewController == nil) {
                        self.presentViewController(errorAlert, animated: true, completion: nil)
                    }
                })
            }
        })
    }

    // MARK - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return FlickrService.sharedInstance.recentPhotos.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : PhotoTableViewCell = tableView.dequeueReusableCellWithIdentifier("photoCell", forIndexPath: indexPath) as! PhotoTableViewCell
        let photo : Photo = FlickrService.sharedInstance.recentPhotos[indexPath.section]
        cell.setUpWithPhoto(photo)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("showProfile", sender:tableView.cellForRowAtIndexPath(indexPath))
    }
}
