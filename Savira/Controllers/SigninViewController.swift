//
//  SigninViewController.swift
//  Savira
//  Copyright © 2020 Palvi. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SigninViewController: UIViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        signInButton.layer.cornerRadius = signInButton.frame.size.height/2
    }
    
    func showError() {
        SVProgressHUD.showError(withStatus: "Looks like it's an invalid credentials.")
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.dismiss(withDelay: 2.0)
    }
    
    @IBAction func signinButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        if validteTextField() {
            getUserData()
        }
    }
    
    func validteTextField() -> Bool {
        if let userNameText = userName.text, userNameText.isEmpty {
            SVProgressHUD.showError(withStatus: "Please enter username")
            return false
        }
        if let passwordText = password.text, passwordText.isEmpty {
            SVProgressHUD.showError(withStatus: "Please enter password")
            return false
        }
        return true
    }
    
    func getUserData() {
        SVProgressHUD.show()
        
        let db = Firestore.firestore()
        db.collection("users").document(userName.text!).getDocument { [weak self] (data, error) in
            guard let self = self else {
                return
            }
            SVProgressHUD.dismiss()
            if let err = error {
                print(err)
            } else {
                if let userData = data {
                    if let userCredentials = userData.data() as? [String: Any] {
                        if let password = userCredentials["password"] as? String,
                            password == self.password.text!,
                            let name = userCredentials["name"] as? String {
                            let imageUrl = userCredentials["imageURL"] as? String
                            self.navigateToWelcomeScreen(userName: name, userImageUrl: imageUrl ?? "")
                        } else {
                            self.showError()
                        }
                    } else {
                        self.showError()
                    }
                }
            }
        }
    }
    
    func navigateToWelcomeScreen(userName: String, userImageUrl: String) {
        UserDefaults.standard.set(userName, forKey: "username")
        UserDefaults.standard.set(userImageUrl, forKey: "imageURL")
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let welcomVc = storyBoard.instantiateInitialViewController()
        self.view.window?.rootViewController = welcomVc
    }
    
}

extension SigninViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
