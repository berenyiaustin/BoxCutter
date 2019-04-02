//
//  ViewController.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/1/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let box = UIView(frame: frame)
        box.backgroundColor = .black
        view.addSubview(box)
        view.backgroundColor = .clear
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = (documentsDirectory as NSString).appendingPathComponent("MC.pdf") as String
        
        let pdfTitle = "Master Carton"
        let pdfMetadata = [
            // The name of the application creating the PDF.
            kCGPDFContextCreator: "Your iOS App",
            
            // The name of the PDF's author.
            kCGPDFContextAuthor: "Foo Bar",
            
            // The title of the PDF.
            kCGPDFContextTitle: "Lorem Ipsum",
            
            // Encrypts the document with the value as the owner password. Used to enable/disable different permissions.
            kCGPDFContextOwnerPassword: "myPassword123"
        ]
        
        // Creates a new PDF file at the specified path.
        UIGraphicsBeginPDFContextToFile(filePath, CGRect.zero, pdfMetadata)
        
        // Creates a new page in the current PDF context.
        UIGraphicsBeginPDFPage()
        
        // Default size of the page is 612x72.
        let pageSize = UIGraphicsGetPDFContextBounds().size
        let font = UIFont.preferredFont(forTextStyle: .largeTitle)
        
        // Let's draw the title of the PDF on top of the page.
        let attributedPDFTitle = NSAttributedString(string: pdfTitle, attributes: [NSAttributedString.Key.font: font])
        let stringSize = attributedPDFTitle.size()
        let stringRect = CGRect(x: (pageSize.width / 2 - stringSize.width / 2), y: 20, width: stringSize.width, height: stringSize.height)
        attributedPDFTitle.draw(in: stringRect)
        
        // Closes the current PDF context and ends writing to the file.
        UIGraphicsEndPDFContext()
        
    }
    
    @IBAction func viewPDF(_ sender: Any) {
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
}
