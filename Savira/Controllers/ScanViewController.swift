//
//  ScanViewController.swift
//  Savira
//  Copyright © 2020 Palvi. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import SVProgressHUD

class ScanViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    let pickerController = UIImagePickerController()

    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!

    var ingredientsList = [IngredientsData]()
    var allergicIngredientsList = [AllergiesData]()
    var recognizedString = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        takePictureButton.layer.cornerRadius = takePictureButton.frame.size.height/2

        pickerController.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

    @IBAction func openCamera() {
        self.imageView.image = nil
        self.messageLabel.text = ""
        self.textField.text = ""
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

}

extension ScanViewController: UIImagePickerControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        recognizedString.removeAll()
        imageView.image = selectedImage

        dismiss(animated: true) {
            SVProgressHUD.show()
            self.performOCR(on: self.imageView.image, recognitionLevel: .accurate)
        }
    }
}

extension ScanViewController:  UINavigationControllerDelegate {
    
}

extension ScanViewController {
    
    func performOCR(on image: UIImage?, recognitionLevel: VNRequestTextRecognitionLevel) {
        guard let image = image else {
            SVProgressHUD.dismiss()
            return
        }

        let ciImage = CIImage(image: image)!
        let requestHandler = VNImageRequestHandler(cgImage: convertCIImageToCGImage(inputImage: ciImage)!, options: [:])

        let request = VNRecognizeTextRequest  { (request, error) in
            if let error = error {
                print(error)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            SVProgressHUD.dismiss()
            for currentObservation in observations {
                let topCandidate = currentObservation.topCandidates(1)
                if let recognizedText = topCandidate.first {
                    print(recognizedText.string)
                    DispatchQueue.main.async {
                        self.methodRecognizedString(string: recognizedText.string)
                    }
                }
            }
        }
        request.recognitionLevel = recognitionLevel

        try? requestHandler.perform([request])
    }

    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        if context != nil {
            return context.createCGImage(inputImage, from: inputImage.extent)
        }
        return nil
    }
    
    func methodRecognizedString(string: String) {
        recognizedString.append(string)
        
        let ingredietNameArray = ingredientsList.filter { (ingredient) -> Bool in
            return recognizedString.contains(ingredient.ingredientName)
        }
        
        if ingredietNameArray.isEmpty {
            self.textField.text = "No Ingredients found"
            self.messageLabel.text = ""
        } else {
            self.textField.text = ingredietNameArray.map({ (ingredient) -> String in
                return ingredient.ingredientName
                }).joined(separator: ",")
            
            var allergyMessages = [String]()
            
            for ingredientName in ingredietNameArray {
                if allergicIngredientsList.contains(where: { $0.ingredientName == ingredientName.ingredientName} ) {
                    let allergicIngredient = allergicIngredientsList.first { (allergicData) -> Bool in
                        return allergicData.ingredientName == ingredientName.ingredientName
                    }
                    
                    if let ingredient = allergicIngredient {
                        if Int(ingredient.allergyValue)! > 0 {
                            allergyMessages.append("\(ingredientName.ingredientName) is not safe to eat.\n\n It has \(ingredient.allergyValue)% level of reaction your health. \n\n It's effect: \(ingredientName.effect).\n")
                             messageLabel.backgroundColor = UIColor.red
                        } else {
                            allergyMessages.append("\(ingredientName.ingredientName)is safe to eat")
                        }
                    }
                } else {
                    allergyMessages.append("\(ingredientName.ingredientName) is safe to eat")
                     messageLabel.backgroundColor = UIColor.green
                }
            }
           
            self.messageLabel.text = allergyMessages.joined(separator: "\n")
            
        }
    }
}

