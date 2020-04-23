//
//  SelectIngredientsTableViewCell.swift
//  Savira
//  Copyright © 2020 Palvi. All rights reserved.
//

import UIKit

class SelectIngredientsTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientNameLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderValueLabel: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    var addIngredientInAllergy: (() -> Void)?
    var removeIngredientInAllergy: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func sliderValueChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            sliderValueLabel.text = "\(Int(slider.value))%"
            if slider.value > 0.9 {
                self.checkBoxButton.isSelected = true
                self.addIngredientInAllergy?()
            } else if slider.value < 0.5 {
                self.checkBoxButton.isSelected = false
                self.removeIngredientInAllergy?()
            }
        }
    }
    
    func populateData(ingredientName: String, allergiesDataLists: [AllergiesData]) {
        self.ingredientNameLabel.text = ingredientName
        
        let allergicIngredient = allergiesDataLists.first { (allergicData) -> Bool in
            return allergicData.ingredientName == ingredientName
        }
        
        if let allergicData = allergicIngredient {
            if let allergyValue = Float(allergicData.allergyValue) {
                slider.value = allergyValue
            }
            
            self.checkBoxButton.isSelected = true
            self.sliderValueLabel.text = allergicData.allergyValue + "%"
        } else {
            slider.value = 0
            self.sliderValueLabel.text = "0%"
            self.checkBoxButton.isSelected = false
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
