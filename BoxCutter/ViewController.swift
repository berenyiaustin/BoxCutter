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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lengthTextField.delegate = self
        widthTextField.delegate = self
        heightTextField.delegate = self
        scrollView.delegate = self
        
        scrollView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 50
        scrollView.zoomScale = 0.25
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: 5000, height: 5000)
    }
    
    @IBAction func generateOutlines(_ sender: Any) {
        
        drawBoxesWithinPDFView(saveToDocumentsWithFileName: "MC.pdf")
        
        // Create and add a PDFView to the view hierarchy.
        
        //let pdfView = PDFView(frame: self.scrollView.subviews[0].bounds)
        //pdfView.autoScales = true
        //view.addSubview(pdfView)
        
        // Create a PDFDocument object and set it as PDFView's document to load the document in that view.
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = (documentsDirectory as NSString).appendingPathComponent("MC.pdf") as String
        //let pdfDocument = PDFDocument(url: URL(fileURLWithPath: filePath))!
        //pdfView.document = pdfDocument
        
        let document = NSData(contentsOfFile: filePath)
        
        let vc = UIActivityViewController(activityItems: [document as Any], applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
    func drawBoxesWithinPDFView(saveToDocumentsWithFileName fileName: String) {
        
        //Dimension Calculations
        let lengthNumber = Double(lengthTextField.text ?? "0")
        let length = (lengthNumber ?? 0) * 72
        
        let widthNumber = Double(widthTextField.text ?? "0")
        let width = (widthNumber ?? 0) * 72
        
        let heightNumber = Double(heightTextField.text ?? "0")
        let height = (heightNumber ?? 0) * 72
        
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
}
