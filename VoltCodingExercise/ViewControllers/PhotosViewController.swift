//
//  PhotosViewController.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit
import PureLayout

extension PhotosViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchTermsArray : [String] = searchController.searchBar.text!.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let searchTerms : Set<String> = Set(searchTermsArray)
        self.fetchContentsForSearchText(searchTerms)
    }
}

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView : UITableView!
    var searchController : UISearchController = UISearchController(searchResultsController: nil)
    var footerViewWithSpinner : UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView = UITableView(frame: self.view.bounds)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        self.tableView.registerClass(PhotoTableViewCell.self, forCellReuseIdentifier: "photoCell")
        self.tableView.estimatedRowHeight = self.view.frame.size.width
        self.tableView.autoPinEdgesToSuperviewEdges()
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.loadPhotos()
        self.initFooterView()
    }

    func initFooterView() {
        self.footerViewWithSpinner = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40.0))
        var bottomSpinner : UIActivityIndicatorView? = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        bottomSpinner!.tag = 10
        self.footerViewWithSpinner.addSubview(bottomSpinner!)
        bottomSpinner!.autoCenterInSuperview()
        bottomSpinner!.hidesWhenStopped = true
        bottomSpinner = nil
    }
    
    func loadPhotos() {
        FlickrService.sharedInstance.getRecentPublicPhotosWithCompletionHandler({(photos : [Photo]?, error : NSError?) -> Void in
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
    
    func searchBarTextIsNotEmpty(searchBarText : String) -> Bool {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        if (searchController.searchBar.text!.stringByTrimmingCharactersInSet(whitespaceSet) != "") {
            return true
        }
        return false
    }
    
    // MARK - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (self.searchController.active) {
            if (self.searchBarTextIsNotEmpty(self.searchController.searchBar.text!)) {
                return FlickrService.sharedInstance.searchedPhotos.count
            }
        }
        return FlickrService.sharedInstance.recentPhotos.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : PhotoTableViewCell = tableView.dequeueReusableCellWithIdentifier("photoCell", forIndexPath: indexPath) as! PhotoTableViewCell
        var photo : Photo
        if (self.searchController.active && self.searchBarTextIsNotEmpty(self.searchController.searchBar.text!)) {
            photo = FlickrService.sharedInstance.searchedPhotos[indexPath.section]
        } else {
            photo = FlickrService.sharedInstance.recentPhotos[indexPath.section]
        }
        cell.setUpWithPhoto(photo)
        if (indexPath.section == FlickrService.sharedInstance.recentPhotos.count - 1) {
            self.loadPhotos()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("showProfile", sender:tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let endOfTable : Bool = (scrollView.contentOffset.y >= ((CGFloat(FlickrService.sharedInstance.recentPhotos.count) * self.view.frame.size.width) - scrollView.frame.size.height))
        if (endOfTable && FlickrService.sharedInstance.dataFetchInProgress && !scrollView.dragging && !scrollView.decelerating) {
            self.tableView.tableFooterView = self.footerViewWithSpinner
            (self.footerViewWithSpinner.viewWithTag(10) as! UIActivityIndicatorView).startAnimating()
        }
    }
    
    // MARK - search
    func fetchContentsForSearchText(searchTerms: Set<String>) {
        FlickrService.sharedInstance.getPhotosForSearchTermsWithCompletionHandler(searchTerms, completionHandler: {(photos : [Photo]?, error : NSError?) -> Void in
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
}
