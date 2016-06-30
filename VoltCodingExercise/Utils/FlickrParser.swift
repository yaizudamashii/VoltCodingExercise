//
//  FlickrParser.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit



class FlickrParser: NSObject {
    static let sharedInstance = FlickrParser()
    
    var dateFormatter : NSDateFormatter = NSDateFormatter()
    
    static func parseResponseFromServer(photoData : [Dictionary<String, String>]?) -> [Photo]! {
        var photos : [Photo] = [Photo]()
        if (photoData == nil || photoData!.count == 0) {
            return photos
        }
        for photoDict in photoData! {
            let photo : Photo = FlickrParser.parseSinglePhoto(photoDict)
            photos.append(photo)
        }
        return photos
    }
    
    static func parseSinglePhoto(photoDict : Dictionary<String, String>) -> Photo! {
        let id : String? = photoDict[kFlickrPhotoIDKey]
        let owner : String? = photoDict[kFlickrPhotoOwnerKey]
        let server : String? = photoDict[kFlickrPhotoServerKey]
        let farm : String? = photoDict[kFlickrPhotoFarmKey]
        let secret : String? = photoDict[kFlickrPhotoSecretKey]
        let title : String? = photoDict[kFlickrPhotoTitleKey]
        
        let photo : Photo = Photo()
        photo.id = id
        photo.owner = owner
        photo.server = server
        photo.farm = farm
        photo.secret = secret
        photo.title = title
        
        return photo
    }
}
