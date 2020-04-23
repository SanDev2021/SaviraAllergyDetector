//
//  SelectIngredientsViewController.swift
//  Savira
//  Copyright © 2020 Palvi. All rights reserved.
//

import UIKit

protocol SelectIngredientsViewControllerDelegate: class {
    func updatedAllergyList(allergiesList: [AllergiesData])
}

class SelectIngredientsViewController: UIViewController {
    
    private let cellIdentifier = "ingredientsCellIdentifier"
    
    var allergiesDataList = [AllergiesData]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var ingredientsArray = [IngredientsData]()
    var searchedIngredientsArray = [IngredientsData]()
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var selectedIngredientsLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: SelectIngredientsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        doneButton.layer.cornerRadius = doneButton.frame.size.height/2
        cancelButton.layer.cornerRadius = cancelButton.frame.size.height/2
        
        self.updateSelectedIngredientsCount()
        
        tableView.register(UINib(nibName: "SelectIngredientsTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    @IBAction func methodCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func methodDone(_ sender: Any) {
        print(allergiesDataList)
        self.delegate?.updatedAllergyList(allergiesList: allergiesDataList)
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSelectedIngredientsCount() {
        selectedIngredientsLabel.text = "\(self.allergiesDataList.count) of \(self.ingredientsArray.count)"
    }
    
    
}

extension SelectIngredientsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedIngredientsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SelectIngredientsTableViewCell
        
        cell.populateData(ingredientName: searchedIngredientsArray[indexPath.row].ingredientName,
                          allergiesDataLists: allergiesDataList)
        
        cell.addIngredientInAllergy = { [weak self] in
            guard let self = self else { return }
            if !self.allergiesDataList.contains(where: { $0.ingredientName == self.searchedIngredientsArray[indexPath.row].ingredientName }) {
                self.allergiesDataList.append(AllergiesData(ingredientName: self.searchedIngredientsArray[indexPath.row].ingredientName,
                                                            allergyValue: String(describing: Int(cell.slider.value))))
            } else {
                
                let allergicIngredient = self.allergiesDataList.first { (allergicData) -> Bool in
                    return allergicData.ingredientName == self.searchedIngredientsArray[indexPath.row].ingredientName
                }
                
                if var allergicData = allergicIngredient {
                    allergicData.allergyValue = String(describing: Int(cell.slider.value))
                    
                    let index = self.allergiesDataList.firstIndex { (allergy) -> Bool in
                        return allergy.ingredientName == self.searchedIngredientsArray[indexPath.row].ingredientName
                    }
                    if let indexToBeUpdated = index {
                        self.allergiesDataList[indexToBeUpdated] = allergicData
                    }
                }
            }
            
            self.updateSelectedIngredientsCount()
        }
        
        cell.removeIngredientInAllergy = { [weak self] in
            guard let self = self else { return }
            let index = self.allergiesDataList.firstIndex { (allergy) -> Bool in
                return allergy.ingredientName == self.searchedIngredientsArray[indexPath.row].ingredientName
            }
            if let indexToBeDeleted = index {
                self.allergiesDataList.remove(at: indexToBeDeleted)
            }
            self.updateSelectedIngredientsCount()
        }
        
        return cell
    }
}

extension SelectIngredientsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.isUserInteractionEnabled = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.isUserInteractionEnabled = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchedIngredientsArray = ingredientsArray
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            filterContentForSearchText(searchText: searchText)
        }
        searchBar.resignFirstResponder()
    }
    
    func filterContentForSearchText(searchText: String) {
        guard !searchText.isEmpty else {
            searchedIngredientsArray = ingredientsArray
            tableView.reloadData()
            return
        }
        searchedIngredientsArray = ingredientsArray.filter({ (ingredient) -> Bool in
            return ingredient.ingredientName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}
