//
//  ImageAnalyzerVC.swift
//  Photo Analyzer
//
//  Created by Ronald Paglinawan on 2/06/19.
//  Copyright © 2019 Paglinawan Technologies. All rights reserved.
//

import UIKit
import Photos
import CoreML
import Vision

class ImageAnalyzerVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  // Action methods
  @IBAction func showAbout(_ sender: Any) {
    let alert = UIAlertController(title: "About Photo Analyzer App", message: "It is a simple machine learning app that allows you to get photos from your camera and photo library then describes what's in the photo with a certain percentage of accuracy. This app was created by Ronald Fornis Paglinawan. Copyright (c) 2019.", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    self.present(alert, animated: true)
  }
  
  @IBAction func analyzePhoto(_ sender: Any) {
    guard let photo = imageView.image else {
      let alert = UIAlertController(title: "No Image Found", message: "Please take a photo or choose from the Photo Library first before tapping the 'Analyze Photo' button", preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      self.present(alert, animated: true)
      return
    }
    makePredictionFor(photo)
  }
  
  @IBAction func showOptions(_ sender: Any) {
    let alert = UIAlertController(title: "Choose an Action", message: "", preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: {(action: UIAlertAction) in
      if UIImagePickerController.isSourceTypeAvailable(.camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
      }
    }))
    
    alert.addAction(UIAlertAction(title: "Choose from Photo Library", style: .default, handler: {(action: UIAlertAction) in
      if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary;
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
      }
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
  }
  
  // imagePickerController delegate methods
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    picker.dismiss(animated: true)
    
    guard let image = info[.editedImage] as? UIImage else {
      print("No image found")
      return
    }
    
    imageView.image = image
  }
  
  // ML custom methods
  func makePredictionFor(_ image: UIImage) {
    guard let model = try? VNCoreMLModel(for: MobileNet().model) else { return }
    let request = VNCoreMLRequest(model: model, completionHandler: handleResults)
    let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
    do {
      try handler.perform([request])
    } catch {
      debugPrint("ERROR: ", error)
    }
  }
  
  func handleResults(request: VNRequest, error: Error?) {
    guard let results = request.results as? [VNClassificationObservation] else { return }
    let bestResult = results[0]
    let id = bestResult.identifier.capitalized
    let confidence = bestResult.confidence * 100
    let confidenceWithTwoDecimals = String(format: "%.2f", confidence)
    descriptionLabel.text = "\(id): \(confidenceWithTwoDecimals)%"
  }
}

