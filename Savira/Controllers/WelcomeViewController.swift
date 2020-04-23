//
//  WelcomeViewController.swift
//  Savira
//  Copyright © 2020 Palvi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SVProgressHUD

struct AllergiesData {
    var ingredientName: String
    var allergyValue: String
}

struct IngredientsData {
    var ingredientName: String
    var effect: String
}

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var checkAllergiesButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var signoutButton: UIButton!
    
    var ingredientsList = [IngredientsData]()
    
    private var allergiesDataList = [AllergiesData]()
    
    var userImageUrl = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.welcomeLabel.text = "Welcome " + (UserDefaults.standard.string(forKey: "username") ?? "")
        
        downloadImage()
        getData()
        
        startButton.layer.cornerRadius = startButton.frame.size.height/2
        checkAllergiesButton.layer.cornerRadius = checkAllergiesButton.frame.size.height/2
        signoutButton.layer.cornerRadius = startButton.frame.size.height/2
    }
    
    @IBAction func showIngredientsList(_ sender: Any) {
        if self.ingredientsList.isEmpty {
            self.getData()
        } else {
            self.performSegue(withIdentifier: "IngredientsListSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IngredientsListSegue",
            let ingredientsListVC = segue.destination as? SelectIngredientsViewController {
            ingredientsListVC.delegate = self
            ingredientsListVC.ingredientsArray = self.ingredientsList
            ingredientsListVC.searchedIngredientsArray = self.ingredientsList
            ingredientsListVC.allergiesDataList = allergiesDataList
        } else if segue.identifier == "ScnaViewControllerSegue",
            let scanVC = segue.destination as? ScanViewController {
            scanVC.ingredientsList = self.ingredientsList
            scanVC.allergicIngredientsList = self.allergiesDataList
        }
    }
    
    func downloadImage() {
        print("Download Started")
        guard let imageURLString = UserDefaults.standard.string(forKey: "imageURL"),
            let imageURL = URL(string: imageURLString)  else {
            return
        }
        getImageData(from: imageURL) { data, response, error in
            guard let data = data, error == nil else { return }
            print("Download Finished")
            DispatchQueue.main.async() {
                self.userImageView.image = UIImage(data: data)
            }
        }
    }
    
    func getImageData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func getData() {
        SVProgressHUD.show()
        
        let db = Firestore.firestore()
        let ingredientsListDbPath = db.collection("IngredientsList").document("Ingredients")
        ingredientsListDbPath.getDocument { [weak self] (data, error) in
            guard let self = self else {
                return
            }
            SVProgressHUD.dismiss()
            if let err = error {
                print(err)
            } else {
                if let ingredientData = data {
                    if let ingredientsNameList = ingredientData.data()?["Ingredients"] as? [[String: Any]] {
                        print(ingredientsNameList)
                        for ingredient in ingredientsNameList {
                            self.ingredientsList.append(IngredientsData(ingredientName: ingredient["name"] as! String,
                                                                        effect: ingredient["effect"] as! String))
                        }
                        self.ingredientsList.sort(by: { $0.ingredientName > $1.ingredientName})
                    }
                }
            }
        }
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "username")
        
        let storyBoard = UIStoryboard(name: "SignInSignup", bundle: nil)
        let initialVc = storyBoard.instantiateInitialViewController()
        self.view.window?.rootViewController = initialVc
    }
}

extension WelcomeViewController: SelectIngredientsViewControllerDelegate {
    func updatedAllergyList(allergiesList: [AllergiesData]) {
        self.allergiesDataList = allergiesList
    }
}
