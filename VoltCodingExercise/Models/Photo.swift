//
//  Photo.swift
//  VoltCodingExercise
//
//  Created by Yuki Konda on 6/30/16.
//  Copyright © 2016 Yuki Konda. All rights reserved.
//

import UIKit

class Photo: NSObject {
    var farm : String?
    var id : String?
    var owner : String?
    var secret : String?
    var server : String?
    var title : String?
    
    func remotePathForMediumSize() -> String? {
        return self.remotePath("m")
    }
    
    func remotePathForLargeSize() -> String? {
        return self.remotePath("b")
    }
    
    func remotePath(size : String) -> String? {
        if (!self.farm.isNilOrEmpty && !self.id.isNilOrEmpty && !self.server.isNilOrEmpty && !self.secret.isNilOrEmpty) {
            return "https://farm\(self.farm!).staticflickr.com/\(self.server!)/\(self.id!)_\(self.secret!)_\(size).jpg"
        }
        return nil
    }
}
