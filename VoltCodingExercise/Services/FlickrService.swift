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
    
    var searchManager : AFHTTPSessionManager!
    var searchTasks : [NSURLSessionDataTask] = [NSURLSessionDataTask]()
    
    var dataFetchInProgress : Bool = false
    var largestPageLoaded : Int = 0
    var recentPhotos : [Photo] = [Photo]()
    var receivedPhotos : Set<String> = Set<String>()
    
    var searchDataFetchInProgress : Bool = false
    var searchTerms : Set<String> = Set<String>()
    var searchLargestPageLoaded : Int = 0
    var searchedPhotos : [Photo] = [Photo]()
    var searchReceivedPhotos : Set<String> = Set<String>()
    
    static func flickrParameters(page : Int) -> NSMutableDictionary {
        return ["api_key" : FlickrService.APIKey,
                "secret" : FlickrService.secret,
                "page" : "\(page)"]
    }
    
    private override init() {
        super.init()
        self.searchManager = AFHTTPSessionManager()
        self.searchManager.requestSerializer = AFHTTPRequestSerializer()
        self.searchManager.responseSerializer = AFHTTPResponseSerializer()
        self.searchManager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/xml") as? Set<String>
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
    
    func getPhotosForSearchTermsWithCompletionHandler(searchTerms : Set<String>, completionHandler : ((photos : [Photo]?, error : NSError?) -> Void)?) {
        if (searchTerms.isEqualToSet(self.searchTerms)) {
            if (self.searchDataFetchInProgress == true) {
                completionHandler?(photos : nil, error : nil)
                return
            }
        } else {
            self.searchTerms = searchTerms
            self.searchLargestPageLoaded = 0
            self.searchedPhotos = [Photo]()
            self.searchReceivedPhotos = Set<String>()
            for task in self.searchTasks {
                task.cancel()
            }
        }
        self.searchDataFetchInProgress = true
        
        let parameters : NSMutableDictionary = FlickrService.flickrParameters(self.searchLargestPageLoaded + 1)
        parameters.setObject(kMethodFlickrSearchForPhotos, forKey: "method")
        parameters.setObject(searchTerms.joinWithSeparator(","), forKey: "tags")
        
        let task : NSURLSessionDataTask? = self.searchManager.GET(FlickrService.FLICKR_REST_API, parameters: parameters, progress:nil, success: { (operation: NSURLSessionTask!, responseObject: AnyObject?) -> Void in
            let responseData : NSData = responseObject as! NSData
            let (photos, pageNumber) = FlickrParser.parseResponseFromServer(responseData)
            for photo in photos {
                if (!self.searchReceivedPhotos.contains(photo.id!)) {
                    self.searchedPhotos.append(photo)
                    self.searchReceivedPhotos.insert(photo.id!)
                }
            }
            if (pageNumber != nil) {
                self.searchLargestPageLoaded = max(self.searchLargestPageLoaded, pageNumber!)
            }
            self.searchDataFetchInProgress = false
            completionHandler?(photos : photos, error : nil)
        }, failure: { (operation: NSURLSessionTask?, error: NSError!) -> Void in
            self.searchDataFetchInProgress = false
            completionHandler?(photos : nil, error: error)
        })
        if (task != nil) {
            self.searchTasks.append(task!)
        }
    }
}