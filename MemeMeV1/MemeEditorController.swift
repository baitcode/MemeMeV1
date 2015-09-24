//
//  MemeEditorController.swift
//  MemeMeV1
//
//  Created by Ilia Batiy on 24/09/15.
//  Copyright (c) 2015 Ilia Batiy. All rights reserved.
//

import Foundation
import UIKit

class MemeEditorController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnShare: UIBarButtonItem!
    @IBOutlet weak var btnCamera: UIBarButtonItem!
    
    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var lblTop: UITextField!
    @IBOutlet weak var lblBottom: UITextField!
    
    @IBOutlet weak var memeView: UIView!
    
    var viewBottomMargineModified: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblBottom.delegate = self;
        self.lblTop.delegate = self;
        
        self.setupState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func setupState(){
        var selected = self.image.image != nil;
        
        self.btnShare.enabled = selected
        self.btnCancel.enabled = selected
        self.btnCamera.enabled = UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera
        )
    }
    
    @IBAction func buttonShareClicked(sender: AnyObject) {
        var meme = self.buildMeme()
        
        let activityController = UIActivityViewController(activityItems: [meme.memedImage],
            applicationActivities: nil
        )
        
        self.presentViewController(activityController, animated: true, completion: nil)
    }

    @IBAction func buttonCancelClicked(sender: AnyObject) {
        self.selectImage(nil)
    }

    func selectImage(image: UIImage?) {
        self.image.image = image
        self.setupState()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.selectImage(info[UIImagePickerControllerOriginalImage] as? UIImage)

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    func presentPicker(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = self
        self.presentViewController(pickerController, animated: false, completion: nil)
    }

    
    @IBAction func buttonCameraClicked(sender: UIBarButtonItem) {
        self.presentPicker(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func buttonAlbumClicked(sender: UIBarButtonItem) {
        self.presentPicker(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardDidShow(notification: NSNotification){
        if (self.lblBottom.isFirstResponder() && !self.viewBottomMargineModified){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            self.viewBottomMargineModified = true
        }
    }

    func keyboardWillHide(notification: NSNotification){
        
        if (self.viewBottomMargineModified){
            self.view.frame.origin.y += getKeyboardHeight(notification)
            self.viewBottomMargineModified = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == ""){
            if (textField == self.lblTop){
                textField.text = "TOP"
            } else {
                textField.text = "BOTTOM"
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        var notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(
            self, selector: "keyboardDidShow:",
            name: UIKeyboardDidShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(
            self, name: UIKeyboardWillShowNotification, object: nil
        )
    }
    
    func generateMemeImage() -> UIImage {
        UIGraphicsBeginImageContext(self.memeView.frame.size)
        self.memeView.drawViewHierarchyInRect(
            self.memeView.frame,
            afterScreenUpdates: true
        )
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    func buildMeme() -> Meme {
        return Meme(
            topText: self.lblTop.text,
            bottomText: self.lblBottom.text,
            image: self.image.image!,
            memedImage: self.generateMemeImage()
        )
    }

}
