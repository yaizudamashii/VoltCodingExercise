//
//  PhotoTableViewCell.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    var photoImageView : UIImageView!
    var photoTitle : UILabel!
    var spinner : UIActivityIndicatorView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let photoImageViewRect : CGRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)
        self.photoImageView = UIImageView(frame: photoImageViewRect)
        self.addSubview(self.photoImageView)
        self.photoImageView.autoPinEdgesToSuperviewEdges()
        
        let titleLabelRect : CGRect = CGRectMake(16, 0, self.frame.size.width - 16, 28)
        self.photoTitle = UILabel(frame: titleLabelRect)
        self.addSubview(self.photoTitle)
        self.photoTitle.autoPinEdge(.Top, toEdge: .Top, ofView: self)
        
        self.spinner = UIActivityIndicatorView()
        self.addSubview(self.spinner)
        self.spinner.hidden = true
        self.spinner.autoCenterInSuperview()
        
        self.backgroundColor = UIColor.lightGrayColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    func setUpWithPhoto(photo : Photo) {
        self.spinner.hidden = false
        self.spinner.startAnimating()
        FlickrService.sharedInstance.getImageForPhotoWithCompletionHandler(photo, imageSize: ImageSize.medium, completionHandler: {(image : UIImage?, error : NSError?) -> Void in
            if (image != nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.photoImageView.image = image
                })
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.spinner.stopAnimating()
                self.spinner.hidden = true
            })
        })
        self.photoTitle.text = photo.title
    }
}
