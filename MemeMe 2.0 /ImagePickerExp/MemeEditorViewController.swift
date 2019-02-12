//
//  ViewController.swift
//  ImagePickerExp
//
//  Created by Alireza Jazzb on 7/10/18.
//  Copyright © 2018 Alireza. All rights reserved.
//


import UIKit

class MemeEditorViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet var cameraButton: UIBarButtonItem!
    @IBOutlet weak var saveMemebutton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let memeTextAttributes:[String: Any] = [
        
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3]
    
  override func viewDidLoad() {
        super.viewDidLoad()

        setupInitialView()
        }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //subscribe to keyboard notifications
        subscribeToKeyboardNotifications()
        //shows camera source when available
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setupInitialView() {
        
        //reset Image Picker View
        imagePickerView.image = nil
        setupTextFieldWithDefaultSettings(textField: topTextField, withText: "TOP")
        setupTextFieldWithDefaultSettings(textField: bottomTextField, withText: "BOTTOM")
        //Disable the share button initially
        saveMemebutton.isEnabled = false
    }
    
    func setupTextFieldWithDefaultSettings(textField: UITextField, withText text: String) {
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = text
        textField.borderStyle = .none
    }
 
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        chooseSourceType(sourceType: .camera)
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        chooseSourceType(sourceType: .photoLibrary)
    }
  
    func chooseSourceType(sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]){
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
            saveMemebutton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0.0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func save(memedImage: UIImage) {
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image!, memeImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        
        hiddenToolBarNavBar(showOption: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        hiddenToolBarNavBar(showOption: false)
        
        return memedImage
    }
    
    func hiddenToolBarNavBar(showOption: Bool) {
        toolBar.isHidden = showOption
        navigationBar.isHidden = showOption
    }
    
    @IBAction func saveMemeAction(_ sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {
            activity, completed, item, error in
            if completed {
                self .save(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        setupInitialView()
        dismiss(animated: true, completion: nil)
    }
    
    
}

