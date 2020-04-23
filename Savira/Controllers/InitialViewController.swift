//
//  InitialViewController.swift
//  Savira
//  Copyright © 2020 Palvi. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        signInButton.layer.cornerRadius = signInButton.frame.size.height/2
        signUpButton.layer.cornerRadius = signUpButton.frame.size.height/2
    }

}
