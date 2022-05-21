//
//  ViewController.swift
//  SeeFood
//
//  Created by Nguyen NGO on 21/05/2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var resultMsg = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Could not convert to CIImage") }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        let alert = UIAlertController(title: "Result", message: resultMsg, preferredStyle: .alert)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    func detect(image: CIImage) {
        

        guard let inceptionModel: Inceptionv3 = try? Inceptionv3(configuration: .init()) else {
            fatalError("Inceptionv3 failed")
            
        }

        guard let model = try? VNCoreMLModel(for: inceptionModel.model) else {
            fatalError("Loading CoreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results else {fatalError("Model failed to process image")}
            
            if let firstResult = results.first {
                
                if firstResult.description.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                    self.resultMsg = "Yeah it's a hotdog 🤤"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                    self.resultMsg = "Not hotdog.."
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    


}
