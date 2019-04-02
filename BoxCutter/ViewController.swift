//
//  ViewController.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/1/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var lengthTextField: UITextField!
    @IBOutlet var widthTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    
    @IBOutlet var faceA: FaceView!
    @IBOutlet var faceB: FaceView!
    @IBOutlet weak var faceA1: FaceView!
    @IBOutlet weak var faceB1: FaceView!
    
    @IBOutlet weak var faceAHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var faceAWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var faceBWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var faceA1HeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lengthTextField.delegate = self
        widthTextField.delegate = self
        heightTextField.delegate = self
        scrollView.delegate = self
        
        faceA.translatesAutoresizingMaskIntoConstraints = false
        faceB.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        scrollView.minimumZoomScale = 0.01
        scrollView.minimumZoomScale = 50
        scrollView.zoomScale = 1
        
        self.setupGestureRecognizer()
        
    }
    
    func setupGestureRecognizer() {
        
    }
    
    @IBAction func viewPDF(_ sender: Any) {
        
        createPdfFromView(aView: self.scrollView.subviews[0], saveToDocumentsWithFileName: "MC.pdf")
        
        // Create and add a PDFView to the view hierarchy.
        let pdfView = PDFView(frame: self.scrollView.subviews[0].bounds)
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
    
    @IBAction func updateDims(_ sender: Any) {
        
        guard let length = NumberFormatter().number(from:
            lengthTextField.text ?? "") else { return }
        
        guard let width = NumberFormatter().number(from:
            widthTextField.text ?? "") else { return }
        
        guard let height = NumberFormatter().number(from:
            heightTextField.text ?? "") else { return }
        
        let flapHeight = Int(truncating: width)/2
        
        UIView.animate(withDuration: 0.3) {
            self.faceAWidthConstraint.constant = CGFloat(truncating: length)
            self.faceAHeightConstraint.constant = CGFloat(truncating: height)
            self.faceBWidthConstraint.constant = CGFloat(truncating: width)
            self.faceA1HeightConstraint.constant = CGFloat(flapHeight)
            self.view.layoutIfNeeded()
        }
    }
}
