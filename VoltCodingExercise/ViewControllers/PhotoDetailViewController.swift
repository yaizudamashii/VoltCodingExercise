//
//  PhotoDetailViewController.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 7/1/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {

    var photo : Photo!
    var scrollView : UIScrollView!
    var photoImageView : UIImageView!
    var photoTitle : UILabel!
    var spinner : UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.view.addSubview(scrollView)
        self.scrollView.minimumZoomScale = 0.25
        self.scrollView.maximumZoomScale = 5.0
        self.scrollView.delegate = self
        self.scrollView.autoPinEdgesToSuperviewEdges()
        
        self.photoImageView = UIImageView(frame: self.view.bounds)
        self.scrollView.addSubview(self.photoImageView)
        self.photoImageView.autoPinEdgesToSuperviewEdges()
        self.photoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let titleLabelRect : CGRect = CGRectMake(0, 0, self.view.frame.size.width, 0)
        self.photoTitle = UILabel(frame: titleLabelRect)
        self.view.addSubview(self.photoTitle)
        self.photoTitle.autoPinEdge(.Top, toEdge: .Top, ofView: self.view)
        self.photoTitle.autoSetDimensionsToSize(CGSizeMake(self.view.frame.size.width, 84))
        self.photoTitle.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        self.photoTitle.numberOfLines = 0
        
        self.spinner = UIActivityIndicatorView()
        self.view.addSubview(self.spinner)
        self.spinner.hidesWhenStopped = true
        self.spinner.startAnimating()
        self.spinner.autoCenterInSuperview()
        
        self.view.backgroundColor = UIColor.lightGrayColor()
        
        FlickrService.sharedInstance.getImageForPhotoWithCompletionHandler(photo, imageSize: ImageSize.large, completionHandler: {(image : UIImage?, error : NSError?) -> Void in
            if (image != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.photoImageView.image = image
                    self.setInitialZoomScale()
                    self.setImageToCenter()
                })
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.spinner.stopAnimating()
                self.spinner.hidden = true
            })
        })
        if (self.photo.title.isNilOrEmpty) {
            self.photoTitle.hidden = true
        } else {
            self.photoTitle.text = self.photo.title
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func setInitialZoomScale() {
        let widthScale : CGFloat = self.scrollView.frame.size.width / self.photoImageView.image!.size.width
        let heightScale : CGFloat = self.scrollView.frame.size.height / self.photoImageView.image!.size.height
        self.scrollView.zoomScale = min(widthScale, heightScale)
    }
    
    func setImageToCenter() {
        var shift = (self.scrollView.frame.size.height - (self.photoImageView.image!.size.height * self.scrollView.zoomScale))/2.0
        self.scrollView.contentInset.top = shift
        shift = (self.scrollView.frame.size.width - (self.photoImageView.image!.size.width * self.scrollView.zoomScale))/2.0
        self.scrollView.contentInset.left = shift
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({(context) in
            self.setInitialZoomScale()
            self.setImageToCenter()
        }, completion: nil)
    }
}
