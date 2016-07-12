//
//  CameraVC.swift
//  Spotlight
//
//  Created by Odin on 2016-06-26.
//  Copyright © 2016 SpotlightTeam. All rights reserved.
//

import UIKit
import CoreLocation

class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var container: CameraViewContainer?
    
    //TODO: delete these @IB* when no one will conflict with the storyboard
    @IBOutlet var PhotoView: UIImageView!
    @IBOutlet var PhotoView2: UIImageView!
    @IBAction func CaptureImage(sender: AnyObject) {}
    @IBAction func GetImageFromAlbums(sender: AnyObject) {}
    @IBAction func SaveButton(sender: AnyObject) {}
    @IBAction func saveLocally(sender: AnyObject) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewContainer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK: Helper Functions
    private func setupViewContainer() {
        container = CameraViewContainer.instanceFromNib(
            CGRectMake(0, 0, view.bounds.width, view.bounds.height))
        container?.delegate = self
        view.addSubview(container!)
    }
}

//MARK: - CameraViewContainerDelegate
extension CameraVC: CameraViewContainerDelegate {
    
    func goToCameraPicker(picker: UIImagePickerController) {
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func dismissViewControllerAnimated() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveToCameraRoll(image: UIImage) {
        //TODO: do I actually need to run this line?
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        CustomPhotoAlbum.sharedInstance.saveImage(image)

    }
    
    func publishImage(image: UIImage) {
        LocalStoragePhotoManager.saveImageLocal(image)
    }
    
    //DEPRACATED: used for debugging
    func publishImage2(image:UIImage) -> UIImage {
        let filePath = LocalStoragePhotoManager.saveImageLocal(image)
        
        return LocalStoragePhotoManager.loadLocalImage(filePath)
    }
}

