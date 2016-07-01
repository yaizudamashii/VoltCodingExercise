//
//  FlickrService.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit
import AFNetworking
import SDWebImage

enum ImageSize: String {
    case medium = "z"
    case large = "b"
}

class FlickrService: NSObject {
    static let sharedInstance = FlickrService()
    
    static let FLICKR_REST_API : String = "https://api.flickr.com/services/rest/"
    static let APIKey : String = "8ff4e3be97b270e0fa3a7beb69125340"
    static let secret : String = "3667574d899a23cd"
    
    var dataFetchInProgress : Bool = false
    var largestPageLoaded : Int = 0
    var recentPhotos : [Photo] = [Photo]()
    var receivedPhotos : Set<String> = Set<String>()
    
    static func flickrParameters(page : Int) -> NSMutableDictionary {
        return ["api_key" : FlickrService.APIKey,
                "secret" : FlickrService.secret,
                "page" : "\(page)"]
    }
    
    func setFlickrHeader(manager : AFHTTPSessionManager!) -> AFHTTPSessionManager {
        manager.requestSerializer.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        return manager
    }
    
    func getRecentPublicPhotosWithCompletionHandler(completionHandler : ((photos : [Photo]?, error : NSError?) -> Void)?) {
        if (self.dataFetchInProgress == true) {
            completionHandler?(photos : nil, error : nil)
            return
        }
        self.dataFetchInProgress = true
        let url : String = "\(FlickrService.FLICKR_REST_API)"
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/xml") as? Set<String>
        let parameters : NSMutableDictionary = FlickrService.flickrParameters(self.largestPageLoaded + 1)
        parameters.setObject(kMethodFlickrGetRecentPublicPhotos, forKey: "method")
        
        manager.GET(url, parameters: parameters, progress:nil, success: { (operation: NSURLSessionTask!, responseObject: AnyObject?) -> Void in
            let responseData : NSData = responseObject as! NSData
            let (photos, pageNumber) = FlickrParser.parseResponseFromServer(responseData)
            for photo in photos {
                if (!self.receivedPhotos.contains(photo.id!)) {
                    self.recentPhotos.append(photo)
                    self.receivedPhotos.insert(photo.id!)
                }
            }
            if (pageNumber != nil) {
                self.largestPageLoaded = max(self.largestPageLoaded, pageNumber!)
            }
            self.dataFetchInProgress = false
            completionHandler?(photos : photos, error : nil)
        }, failure: { (operation: NSURLSessionTask?, error: NSError!) -> Void in
            self.dataFetchInProgress = false
            completionHandler?(photos : nil, error: error)
        })
    }
    
    func getImageForPhotoWithCompletionHandler(photo : Photo, imageSize : ImageSize, completionHandler : ((image : UIImage?, error : NSError?) -> Void)?) {
        var remotePath : String?
        if (imageSize == ImageSize.medium) {
            remotePath = photo.remotePathForMediumSize()
        } else if (imageSize == ImageSize.large) {
            remotePath = photo.remotePathForLargeSize()
        }
        if (!remotePath.isNilOrEmpty) {
            let url : NSURL = NSURL(string: remotePath!)!
            let manager : SDWebImageManager = SDWebImageManager.sharedManager()
            manager.downloadImageWithURL(url, options: [], progress: nil, completed: {(image : UIImage?, error : NSError?, cacheType : SDImageCacheType?, finished : Bool?, imageURL : NSURL?) -> Void in
                if (image != nil) {
                    completionHandler?(image: image, error : nil)
                } else {
                    completionHandler?(image: nil, error : error)
                }
            })
        }
    }
}