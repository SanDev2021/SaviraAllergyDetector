//
//  SignupViewController.swift
//  Savira
//  Copyright © 2020 Palvi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SVProgressHUD

class SignupViewController: UIViewController {
    
    /// Name of the User
    @IBOutlet weak var name: UITextField!
    
    /// userName of the User
    @IBOutlet weak var userName: UITextField!
    
    /// Email of the User
    @IBOutlet weak var email: UITextField!
    
    /// password of the User
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var userImageButton: UIButton!
    let pickerController = UIImagePickerController()
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        pickerController.delegate = self
        signUpButton.layer.cornerRadius = signUpButton.frame.size.height/2
    }
    
    func validteTextField() -> Bool {
        if let nameText = name.text, nameText.isEmpty {
            SVProgressHUD.showError(withStatus: "Please enter name")
            return false
        }
        if let userNameText = userName.text, userNameText.isEmpty {
            SVProgressHUD.showError(withStatus: "Please enter username")
            return false
        }
        if let emailText = email.text, emailText.isEmpty {
            SVProgressHUD.showError(withStatus: "Please enter email")
            return false
        }
        if let passwordText = password.text, passwordText.isEmpty {
            SVProgressHUD.showError(withStatus: "Please enter password")
            return false
        }
        return true
    }
    
    @IBAction func userImageButtonClicked(_ sender: Any) {
        if (UIImagePickerController .isSourceTypeAvailable(.camera))
        {
            pickerController.sourceType = .camera
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        }
        else if (UIImagePickerController .isSourceTypeAvailable(.photoLibrary)) {
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            self.present(pickerController, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signupButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        if validteTextField() {
            saveUserData()
        }
    }
    
    func saveUserData() {
        SVProgressHUD.show()
        
        if let imageData = userImageButton.backgroundImage(for: .normal)!.jpegData(compressionQuality: 0.1) {
            let imageRef = Storage.storage().reference().child("\(userName.text!).jpg")
            
            let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!\
                        return
                    }
                    print(downloadURL)
                    
                    let userData: [String: Any] = ["name": self.name.text!,
                                                   "password": self.password.text!,
                                                   "email": self.email.text!,
                                                   "username": self.userName.text!,
                                                   "imageURL": downloadURL.description]
                    
                    self.uploadUSerData(userData: userData)
                }
            }
            
            uploadTask.observe(.success) { (snapshot) in
                SVProgressHUD.dismiss()
                print(snapshot)
            }
            
            uploadTask.observe(.failure) { snapshot in
                SVProgressHUD.dismiss()
                print(snapshot.error!)
            }
        }
    }
    
    func uploadUSerData(userData: [String: Any]) {
        SVProgressHUD.show()
        let db = Firestore.firestore()
        let usersDbPath = db.collection("users").document(userName.text!)
        
        usersDbPath.setData(userData) { err in
            SVProgressHUD.dismiss()
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                UserDefaults.standard.set(userData["imageURL"] as! String, forKey: "imageURL")
                self.navigateToWelcomeScreen()
            }
        }
    }
    
    func navigateToWelcomeScreen() {
        UserDefaults.standard.set(name.text!, forKey: "username")
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let welcomVc = storyBoard.instantiateInitialViewController()
        self.view.window?.rootViewController = welcomVc
    }
}

extension SignupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

extension SignupViewController: UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        userImageButton.setBackgroundImage(selectedImage, for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}

extension SignupViewController:  UINavigationControllerDelegate {
    
}
