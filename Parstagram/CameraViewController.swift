//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Wei Nie on 2/23/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    
    @IBAction func onSubmitButton(_ sender: Any) {
        let post = PFObject(className: "Posts")
        post["caption"] = commentField.text
        post["author"] = PFUser.current()!
        
        let imageData = cameraImageView.image?.pngData()
        /*let file = PFFileObject(data: imageData!)*/
        
        let file = PFFileObject(name:"image.png", data:imageData!)
        
        post["image"] = file
        
        post.saveInBackground(){(success, error) in
            if(success){
                self.dismiss(animated: true, completion: nil)
                print("success")
            }else{
                print("failure")
            }
            
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        cameraImageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
