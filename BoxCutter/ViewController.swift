//
//  ViewController.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/1/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var lengthTextField: UITextField!
    @IBOutlet var widthTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    
    @IBOutlet var faceA: FaceView!
    @IBOutlet var faceB: FaceView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func viewPDF(_ sender: Any) {
        
        guard let length = NumberFormatter().number(from:
            lengthTextField.text ?? "") else { return }
        
        guard let width = NumberFormatter().number(from:
            widthTextField.text ?? "") else { return }
        
        guard let height = NumberFormatter().number(from:
            heightTextField.text ?? "") else { return }
        
        faceA.widthAnchor.constraint(equalToConstant: CGFloat(truncating: length))
        
        createPdfFromView(aView: self.view, saveToDocumentsWithFileName: "MC.pdf")
        
        // Create and add a PDFView to the view hierarchy.
        let pdfView = PDFView(frame: view.bounds)
        pdfView.autoScales = true
        view.addSubview(pdfView)
        
        // Create a PDFDocument object and set it as PDFView's document to load the document in that view.
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = (documentsDirectory as NSString).appendingPathComponent("MC.pdf") as String
        let pdfDocument = PDFDocument(url: URL(fileURLWithPath: filePath))!
        pdfView.document = pdfDocument
        
        let document = NSData(contentsOfFile: filePath)
        
        let vc = UIActivityViewController(activityItems: [document as Any], applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String)
    {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            debugPrint(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.layoutIfNeeded()
    }
}
