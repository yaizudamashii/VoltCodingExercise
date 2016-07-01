//
//  FlickrParser.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit
import SWXMLHash

class FlickrParser: NSObject {
    static let sharedInstance = FlickrParser()
    
    var dateFormatter : NSDateFormatter = NSDateFormatter()
    
    static func parseResponseFromServer(photoData : NSData?) -> (photos : [Photo]!, pageNmber : Int?) {
        var photos : [Photo] = [Photo]()
        if (photoData == nil || photoData!.length == 0) {
            return (photos, nil)
        }
        let responseXML : String = String(data: photoData!, encoding: NSUTF8StringEncoding)!
        let xmlDoc = SWXMLHash.parse(responseXML)
        
        var pageNumber : Int?
        let pageNumberStr : String? = xmlDoc[kFlickrXMLRespKey][kFlickrXMLPhotosKey].element?.attributes[kFlickrXMLPageKey]
        if (!pageNumberStr.isNilOrEmpty) {
            pageNumber = Int(pageNumberStr!)
        }
        
        for elem in xmlDoc[kFlickrXMLRespKey][kFlickrXMLPhotosKey][kFlickrXMLPhotoKey] {
            let photo : Photo = FlickrParser.parseSinglePhoto(elem)
            photos.append(photo)
        }
        
        return (photos, pageNumber)
    }
    
    static func parseSinglePhoto(photoElem : XMLIndexer) -> Photo! {
        let id : String? = photoElem.element?.attributes[kFlickrXMLPhotoIDKey]
        let owner : String? = photoElem.element?.attributes[kFlickrXMLPhotoOwnerKey]
        let server : String? = photoElem.element?.attributes[kFlickrXMLPhotoServerKey]
        let farm : String? = photoElem.element?.attributes[kFlickrXMLPhotoFarmKey]
        let secret : String? = photoElem.element?.attributes[kFlickrXMLPhotoSecretKey]
        let title : String? = photoElem.element?.attributes[kFlickrXMLPhotoTitleKey]
        
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
