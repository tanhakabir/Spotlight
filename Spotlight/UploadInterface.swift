//
//  UploadInterface.swift
//  Spotlight
//
//  Created by Odin on 2016-07-31.
//  Copyright © 2016 SpotlightTeam. All rights reserved.
//

import Foundation
import Photos
import Firebase

protocol UploadInterfaceProtocol {
    /// Uploads a photo to online storage.
    /// - Requires: the user must be signed in
    /// - Postcondition: completion returns error or nil
    func uploadPhoto(photo: Photo, completed: (err: ErrorType?) -> ())
    func uploadPhotoInfo(photo: Photo, completed: (err: ErrorType?) -> ())
    func createPhotoInfo() -> PhotoInfo
}

extension ModelInterface: UploadInterfaceProtocol {
    func uploadPhoto(photo: Photo, completed: (err: ErrorType?) -> ()) {
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL(FirebaseConstants.storageURL)
        
        if let onlinePath = photo.photoInfo?.onlineStoragePath {
            let photoRef = storageRef.child(onlinePath)
            let imageData = UIImageJPEGRepresentation(photo.photoImage, 0.1)
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            //INFO: https://firebase.google.com/docs/reference/ios/firebasestorage/interface_f_i_r_storage_upload_task
            // we should consider using uploadTask to pause and resume upload
            photoRef.putData(imageData!, metadata: metaData) { metadata, error in
                if (error != nil) {
                    Log.error("\(onlinePath) failed to upload!")
                    completed(err: UploadError.FailedUploadPhoto)
                } else {
                    Log.info("uploaded an image: \(onlinePath)")
                    completed(err: nil)
                }
            }
        } else {
            completed(err: UploadError.FailedUploadPhoto)
        }
    }

    func uploadPhotoInfo(photo: Photo, completed: (err: ErrorType?) -> ()) {
        guard photo.photoInfo != nil else {
            Log.error("photo info you tried to upload has photoPath")
            completed(err: UploadError.FailedUploadPhotoInfo)
            return
        }
        
        Log.debug("about to upload: \(photo.photoInfo!.onlineStoragePath)")
        
        let firebaseRef = FIRDatabase.database().reference()
        
        
        let geoBlockKey = Location.sharedInstance.getGeoBlockKey()
        let bigGeoBlockKey = Location.sharedInstance.getBigGeoBlockKey()
        
        let photoInfoToUpload = ["userID": photo.photoInfo!.userKey,
                                   "name": photo.photoInfo!.name,
                                   "lat": photo.photoInfo!.lat,
                                   "lon": photo.photoInfo!.lon,
                                   "timeStamp": photo.photoInfo!.timeStamp]
        
        let childUpdates = ["/\(PermanentConstants.realTimeDatabasePhotoInfo)/\(photo.photoInfo!.key)": photoInfoToUpload,
                            "/\(PermanentConstants.realTimeDatabaseUserInfo)/\(photo.photoInfo!.userKey)/\(PermanentConstants.realTimeDatabasePhotoInfo)/\(photo.photoInfo!.key)/": 1,
                            "/\(PermanentConstants.realTimeDatabaseBigGeoBlock)/\(bigGeoBlockKey)/\(geoBlockKey)": 1,
                            "/\(PermanentConstants.realTimeDatabaseGeoBlock)/\(geoBlockKey)/\(photo.photoInfo!.key)": (photo.photoInfo?.timeStamp)!]
        
        firebaseRef.updateChildValues(childUpdates, withCompletionBlock: {(error,ref) in
            if(error != nil) {
                Log.error("Could not update image metadata of image:\(photo.photoInfo?.name)")
            } else {
                //TODO: return photo
                //completed(photoEntity: photoEntity)
            }
        })
    }
    
    func createPhotoInfo() -> PhotoInfo {
        let firebaseRef = FIRDatabase.database().reference()
        let photoInfoKey = firebaseRef.child(PermanentConstants.realTimeDatabasePhotoInfo).childByAutoId().key
        let userKey = FIRAuth.auth()?.currentUser?.uid
        
         return PhotoInfo(userKey: userKey!, photoInfoKey: photoInfoKey, lat: Location.sharedInstance.currentLat, lon: Location.sharedInstance.currentLat, timeStamp: NSDate().fireBaseImageTimeStamp())
    }
}

