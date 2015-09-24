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
    
    var meme: Meme?
    
    var viewBottomMargineModified: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblBottom.delegate = self
        lblTop.delegate = self
        
        setupState()
    }
    
    func setupTextStyle(label: UITextField){
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.Center
        
        label.defaultTextAttributes = [
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 30)!,
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSStrokeWidthAttributeName: -4,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSBackgroundColorAttributeName: UIColor.clearColor(),
            NSParagraphStyleAttributeName: paragraph,
        ]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setupState(){
        let selected = image.image != nil;
        
        btnShare.enabled = selected
        btnCancel.enabled = selected
        btnCamera.enabled = UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera
        )
        
        setupTextStyle(lblTop)
        setupTextStyle(lblBottom)
    }
    
    @IBAction func buttonShareClicked(sender: AnyObject) {
        if let meme = buildMeme() {
            let activityController = UIActivityViewController(
                activityItems: [meme.memedImage],
                applicationActivities: nil
            )
            activityController.completionWithItemsHandler = { activity, success, items, error in
                if success {
                    self.meme = meme
                }
            }
            
            presentViewController(activityController, animated: true, completion: nil)
        }
    }

    @IBAction func buttonCancelClicked(sender: AnyObject) {
        selectImage(nil)
    }

    func selectImage(image: UIImage?) {
        self.image.image = image
        setupState()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        selectImage(info[UIImagePickerControllerOriginalImage] as? UIImage)

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    func presentPicker(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = self
        presentViewController(pickerController, animated: false, completion: nil)
    }

    
    @IBAction func buttonCameraClicked(sender: UIBarButtonItem) {
        presentPicker(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func buttonAlbumClicked(sender: UIBarButtonItem) {
        presentPicker(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if (lblBottom.isFirstResponder()) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
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
            if (textField == lblTop){
                textField.text = "TOP"
            } else {
                textField.text = "BOTTOM"
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
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
        UIGraphicsBeginImageContext(memeView.frame.size)
        memeView.drawViewHierarchyInRect(
            memeView.frame,
            afterScreenUpdates: true
        )
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    func buildMeme() -> Meme! {
        return Meme(
            topText: lblTop.text!,
            bottomText: lblBottom.text!,
            image: image.image!,
            memedImage: generateMemeImage()
        )
    }

}
