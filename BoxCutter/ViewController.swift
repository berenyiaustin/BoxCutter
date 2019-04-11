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

    public var isInches = true
    var unit = 72.00
    var multiplier = 2.5
    
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var unitsSwitch: UISwitch!
    
    @IBOutlet weak var mockA: UIView!
    @IBOutlet weak var mockB: UIView!
    
    @IBOutlet weak var previewLabel: UILabel!
    
    @IBOutlet weak var mockAHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mockAWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var mockBWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mockATopHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var lengthTextField: UITextField!
    @IBOutlet var widthTextField: UITextField!
    @IBOutlet var heightTextField: UITextField!
    
    let impact = UIImpactFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mockA.translatesAutoresizingMaskIntoConstraints = false
        
        lengthTextField.delegate = self
        widthTextField.delegate = self
        heightTextField.delegate = self
        scrollView.delegate = self
        
        scrollView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 50
        scrollView.zoomScale = 0.25
        
        UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut, animations: {
            
        }, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: 5000, height: 5000)
    }
    
    @IBAction func generateOutlines(_ sender: Any) {
        
        impact.impactOccurred()
        
        //TextField errors
        let textFields = [lengthTextField,widthTextField,heightTextField]
        for textField in textFields {
            if textField?.text == "" {
                textField?.shake(count: 3, for: 0.2, withTranslation: 8)
            }
        }
        
        //TextField success
        if lengthTextField.text != "" && widthTextField.text != "" && heightTextField.text != "" {
            
            drawBoxesWithinPDFView(saveToDocumentsWithFileName: "MC.pdf")
            
            // Create a PDFDocument object and set it as PDFView's document to load the document in that view.
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = (documentsDirectory as NSString).appendingPathComponent("MC.pdf") as String
            let document = NSData(contentsOfFile: filePath)
            let vc = UIActivityViewController(activityItems: [document as Any], applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func drawBoxesWithinPDFView(saveToDocumentsWithFileName fileName: String) {
        
        //Dimension Calculations
        let lengthNumber = Double(lengthTextField.text ?? "0")
        let length = (lengthNumber ?? 0) * unit
        
        let widthNumber = Double(widthTextField.text ?? "0")
        let width = (widthNumber ?? 0) * unit
        
        let heightNumber = Double(heightTextField.text ?? "0")
        let height = (heightNumber ?? 0) * unit
        
        let totalWidth = (length * 2) + (width * 2) + 72 + 25
        let totalHeight = height + width + 25
        
        let pageRect = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        //Render
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            
            //Draw
            
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(1)
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: (width/2) + 72))
            path.addLine(to: CGPoint(x: 72, y: (width/2)))
            path.addLine(to: CGPoint(x: 72, y: (width/2) + height))
            path.addLine(to: CGPoint(x: 0, y: (width/2) + height - 72))
            path.closeSubpath()
            ctx.cgContext.addPath(path)
            
            //Draw flaps first to keep them below main faces
            
            let faceAtop = CGRect(x: 72, y: 0, width: length, height: width/2)
            ctx.cgContext.addRect(faceAtop)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceAbottom = CGRect(x: 72, y: (width/2) + height, width: length, height: width/2)
            ctx.cgContext.addRect(faceAbottom)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceBtop = CGRect(x: length + 72, y: 0, width: width, height: width/2)
            ctx.cgContext.addRect(faceBtop)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceBbottom = CGRect(x: length + 72, y: (width/2) + height, width: width, height: width/2)
            ctx.cgContext.addRect(faceBbottom)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceCtop = CGRect(x: length + width + 72, y: 0, width: length, height: width/2)
            ctx.cgContext.addRect(faceCtop)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceCbottom = CGRect(x: length + width + 72, y: (width/2) + height, width: length, height: width/2)
            ctx.cgContext.addRect(faceCbottom)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceDtop = CGRect(x: length + width + length + 72, y: 0, width: width, height: width/2)
            ctx.cgContext.addRect(faceDtop)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceDbottom = CGRect(x: length + width + length + 72, y: (width/2) + height, width: width, height: width/2)
            ctx.cgContext.addRect(faceDbottom)
            ctx.cgContext.drawPath(using: .stroke)
            
            //Draw main faces last to keep them on top
            
            let faceA = CGRect(x: 72, y: width/2, width: length, height: height)
            ctx.cgContext.addRect(faceA)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceB = CGRect(x: length + 72, y: width/2, width: width, height: height)
            ctx.cgContext.addRect(faceB)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceC = CGRect(x: length + width + 72, y: width/2, width: length, height: height)
            ctx.cgContext.addRect(faceC)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceD = CGRect(x: length + width + length + 72, y: width/2, width: width, height: height)
            ctx.cgContext.addRect(faceD)
            ctx.cgContext.drawPath(using: .stroke)
            
            //Add Text
            let warningString = "Be CAREFUL when opening box. Your gear inside doesn’t like to be poked by knives."
            
            drawRotatedText(warningString, at: CGPoint(x: faceAtop.size.width/2 + 72, y: 0), angle: 180)
            drawRotatedText(warningString, at: CGPoint(x: faceAbottom.size.width/2 + 72, y: CGFloat(width + height)), angle: 0)
            drawRotatedText(warningString, at: CGPoint(x: 72 + CGFloat(length + width) + faceCtop.size.width/2, y: 0), angle: 180)
            drawRotatedText(warningString, at: CGPoint(x: 72 + CGFloat(length + width) + faceCbottom.size.width/2, y: CGFloat(width + height)), angle: 0)
            
            //Add Image
//            let getOutdoors = UIImage(named: "getOutdoors")
//            getOutdoors?.draw(at: CGPoint(x: 0, y: 0))
//            getOutdoors.
            
        }
        
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        
        docURL = docURL?.appendingPathComponent("MC.pdf")
        
        //Lastly, write your file to the disk.
        
        do {
            try data.write(to: docURL!)
        } catch {
            print("error")
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    
    func drawRotatedText(_ text: String, at p: CGPoint, angle: CGFloat) {
        // Draw text centered on the point, rotated by an angle in degrees moving clockwise.
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont(name: "Helvetica-Bold", size: 16),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        let textSize = text.size(withAttributes: attributes as [NSAttributedString.Key : Any])
        let c = UIGraphicsGetCurrentContext()!
        c.saveGState()
        // Translate the origin to the drawing location and rotate the coordinate system.
        c.translateBy(x: p.x, y: p.y)
        c.rotate(by: angle * .pi / 180)
        // Draw the text centered at the point.
        text.draw(at: CGPoint(x: -textSize.width / 2, y: (-textSize.height * 2) + 10), withAttributes: attributes as [NSAttributedString.Key : Any])
        // Restore the original coordinate system.
        c.restoreGState()
    }
    
    @IBAction func unitsSwitchDidTouch(_ sender: Any) {
        
        if unitsSwitch.isOn {
            
            clearTextFields()
            
            self.isInches = false
            //CENTIMETER MULTIPLIER
            self.multiplier = 1.5
            self.unit = 28.346
            self.unitsLabel.text = "CENTIMETERS"
        } else {
            
            clearTextFields()
            
            self.isInches = true
            //INCH MULTIPLIER
            self.multiplier = 3
            self.unit = 72
            self.unitsLabel.text = "INCHES"
        }
    }
    
    func clearTextFields() {
        
        let textFields = [lengthTextField,widthTextField,heightTextField]
        
        for textField in textFields {
            if let field = textField {
                field.text = ""
            }
        }
    }
    
    @IBAction func lengthEditingChanged(_ sender: Any) {
        if let lengthDouble = Double(lengthTextField.text ?? "") {
            let length = CGFloat(lengthDouble * multiplier)
            
            UIView.animate(withDuration: 0.5) {
                self.previewLabel.alpha = 0
                self.mockAWidthConstraint.constant = length
                self.view.layoutIfNeeded()
            }
        }
    }
    @IBAction func widthEditingChanged(_ sender: Any) {
        if let widthDouble = Double(widthTextField.text ?? "") {
            let width = CGFloat(widthDouble * multiplier)
            
            UIView.animate(withDuration: 0.5) {
                self.previewLabel.alpha = 0
                self.mockBWidthConstraint.constant = width
                self.mockATopHeightConstraint.constant = width/2
                self.view.layoutIfNeeded()
            }
        }
    }
    @IBAction func heightEditingChanged(_ sender: Any) {
        
        if let heightDouble = Double(heightTextField.text ?? "") {
            let height = CGFloat(heightDouble * multiplier)
                
            UIView.animate(withDuration: 0.5) {
                self.previewLabel.alpha = 0
                self.mockAHeightConstraint.constant = height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
