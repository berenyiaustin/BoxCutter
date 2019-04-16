//
//  ViewController.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/1/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreImage

class MainViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIDocumentPickerDelegate {

    var items:[(sku:String, length:String, width:String, height:String, asin:String, itemName:String)]?
    
    var generatingFromFile = false
    
    let theme = Theme.theme1
    let defaults = UserDefaults.standard
    
    public var isInches = true
    var unit = 72.00
    var multiplier = 2.5
    
    var fileName = "MC"
    var itemName = "(ITEM NAME)"
    var asin = "(ASIN)"
    
    var length = Double()
    var width = Double()
    var height = Double()
    
    @IBOutlet weak var previewWindow: UIView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var dimensionsStackView: UIStackView!
    @IBOutlet weak var controlsViewBottomConstraint: NSLayoutConstraint!
    
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
    @IBOutlet weak var fileNameTextField: BoxCutterTextField!
    
    let impact = UIImpactFeedbackGenerator()
    
    var error: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //upcImageView.image = MainViewController.fromString(string: "855020001670")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.numberOfTapsRequired = 1
        previewWindow.addGestureRecognizer(tap)
        
        lengthTextField.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        mockA.translatesAutoresizingMaskIntoConstraints = false
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        
        lengthTextField.delegate = self
        widthTextField.delegate = self
        heightTextField.delegate = self
        fileNameTextField.delegate = self
        fileNameTextField.autocorrectionType = .no
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationController?.navigationBar.backgroundColor = theme.backgroundColor
        self.navigationController?.navigationBar.barTintColor = theme.backgroundColor
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func uploadCSVFile(_ sender: Any) {
        
        generatingFromFile = true
        
        let types: [String] = [kUTTypeCommaSeparatedText as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func generateOutlines(_ sender: Any) {
        
        generatingFromFile = false
        
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
            
            if let fileNameString = fileNameTextField.text {
                fileName = fileNameString
                //Append suffix if it exists
                if let suffix = self.defaults.string(forKey: "fileNameSuffix") {
                    fileName.append(" \(suffix)")
                }
                drawBoxesWithinPDFView(lengthFromFile: nil,
                                       widthFromFile: nil,
                                       heightFromFile: nil,
                                       asin: nil,
                                       itemName: nil,
                                       saveToDocumentsWithFileName: "\(fileName).pdf")
            } else {
                drawBoxesWithinPDFView(lengthFromFile: nil,
                                       widthFromFile: nil,
                                       heightFromFile: nil,
                                       asin: nil,
                                       itemName: nil,
                                       saveToDocumentsWithFileName: "\(fileName).pdf")
            }
            
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = (documentsDirectory as NSString).appendingPathComponent("\(fileName).pdf") as String
            let url = NSURL(fileURLWithPath: filePath)
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func batchGenerateOutlinesFor(items: [(sku:String, length:String, width:String, height:String, asin:String, itemName:String)]) {
        
        clearDiskCache()
        
        for item in items {
            self.fileName = item.sku
            
            if let suffix = self.defaults.string(forKey: "fileNameSuffix") {
                fileName.append(" \(suffix)")
            }
            
            let length = Double(item.length)
            let width = Double(item.width)
            let height = Double(item.height)
            self.asin = item.asin
            self.itemName = item.itemName
            
            drawBoxesWithinPDFView(lengthFromFile: length,
                                   widthFromFile: width,
                                   heightFromFile: height,
                                   asin: asin,
                                   itemName: itemName,
                                   saveToDocumentsWithFileName: "\(fileName).pdf")
        }
        
        if let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last {
            
            let vc = UIActivityViewController(activityItems: [docURL as URL], applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
        } else {
            print("There was an error.")
        }
        
    }
    
    func clearDiskCache() {
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }
    
    func drawBoxesWithinPDFView(lengthFromFile: Double?,
                                widthFromFile: Double?,
                                heightFromFile: Double?,
                                asin: String?,
                                itemName: String?,
                                saveToDocumentsWithFileName: String) {
        
        if generatingFromFile == false {
            if let lengthNumber = lengthTextField.text {
                length = Double(lengthNumber)! * unit
            }
            if let widthNumber = widthTextField.text {
                width = Double(widthNumber)! * unit
            }
            if let heightNumber = heightTextField.text {
                height = Double(heightNumber)! * unit
            }
        } else {
            if let lengthFromFile = lengthFromFile {
                length = lengthFromFile * unit
            }
            if let widthFromFile = widthFromFile {
                width = widthFromFile * unit
            }
            if let heightFromFile = heightFromFile {
                height = heightFromFile * unit
            }
        }
        
        //Dimension Calculations
        
        let totalWidth = (length * 2) + (width * 2) + 72 + 25
        let totalHeight = height + width + 25
        let tabWidth = 72.00
        
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
            path.move(to: CGPoint(x: 0, y: (width/2) + tabWidth))
            path.addLine(to: CGPoint(x: tabWidth, y: (width/2)))
            path.addLine(to: CGPoint(x: tabWidth, y: (width/2) + height))
            path.addLine(to: CGPoint(x: 0, y: (width/2) + height - tabWidth))
            path.closeSubpath()
            ctx.cgContext.addPath(path)
            
            //Draw flaps first to keep them below main faces
            
            let faceAtop = CGRect(x: tabWidth, y: 0, width: length, height: width/2)
            ctx.cgContext.addRect(faceAtop)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceAbottom = CGRect(x: tabWidth, y: (width/2) + height, width: length, height: width/2)
            ctx.cgContext.addRect(faceAbottom)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceBtop = CGRect(x: length + tabWidth, y: 0, width: width, height: width/2)
            ctx.cgContext.addRect(faceBtop)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceBbottom = CGRect(x: length + tabWidth, y: (width/2) + height, width: width, height: width/2)
            ctx.cgContext.addRect(faceBbottom)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceCtop = CGRect(x: length + width + tabWidth, y: 0, width: length, height: width/2)
            ctx.cgContext.addRect(faceCtop)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceCbottom = CGRect(x: length + width + tabWidth, y: (width/2) + height, width: length, height: width/2)
            ctx.cgContext.addRect(faceCbottom)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceDtop = CGRect(x: length + width + length + tabWidth, y: 0, width: width, height: width/2)
            ctx.cgContext.addRect(faceDtop)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceDbottom = CGRect(x: length + width + length + tabWidth, y: (width/2) + height, width: width, height: width/2)
            ctx.cgContext.addRect(faceDbottom)
            ctx.cgContext.drawPath(using: .stroke)
            
            //Draw main faces last to keep them on top
            
            let faceA = CGRect(x: tabWidth, y: width/2, width: length, height: height)
            ctx.cgContext.addRect(faceA)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceB = CGRect(x: length + tabWidth, y: width/2, width: width, height: height)
            ctx.cgContext.addRect(faceB)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceC = CGRect(x: length + width + tabWidth, y: width/2, width: length, height: height)
            ctx.cgContext.addRect(faceC)
            ctx.cgContext.drawPath(using: .stroke)
            
            let faceD = CGRect(x: length + width + length + tabWidth, y: width/2, width: width, height: height)
            ctx.cgContext.addRect(faceD)
            ctx.cgContext.drawPath(using: .stroke)
            
            //Add Text
            
            let itemHeaderFont = UIFont(name: "HelveticaNeue-Bold", size: 56)
            let itemHeaderAttributes = [
                NSAttributedString.Key.font: itemHeaderFont,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            
            let itemNameFont = UIFont(name: "HelveticaNeue", size: 12)
            let itemNameAttributes = [
                NSAttributedString.Key.font: itemNameFont,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            
            let exportInfoFont = UIFont(name: "HelveticaNeue", size: 18)
            let exportInfoAttributes = [
                NSAttributedString.Key.font: exportInfoFont,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            
            let shortenedName = self.fileName.components(separatedBy: " ")
            let itemNameUppercased = self.itemName.uppercased()
            
            let itemHeader = NSMutableAttributedString(string: "ITEM #: \(shortenedName[0])", attributes: itemHeaderAttributes as [NSAttributedString.Key : Any])
            let itemName = NSMutableAttributedString(string: "\nITEM NAME: \(itemNameUppercased)", attributes: itemNameAttributes as [NSAttributedString.Key : Any])
            let exportInfo = NSMutableAttributedString(string: "\n\n\nASIN: \(self.asin)\nQTY: \nPO#:\nNET WEIGHT (KG):\nGROSS WEIGHT (KG):\nCARTON DIMS:\nMADE IN CHINA", attributes: exportInfoAttributes as [NSAttributedString.Key : Any])
            
            itemHeader.append(itemName)
            itemHeader.append(exportInfo)
            itemHeader.draw(in: faceB.insetBy(dx: 35, dy: 20))
            itemHeader.draw(in: faceD.insetBy(dx: 35, dy: 20))
            
            if let warning = self.defaults.string(forKey: "cutWarningText") {
                drawRotatedWarningText(warning, at: CGPoint(x: faceAtop.size.width/2 + CGFloat(tabWidth), y: 0), angle: 180)
                drawRotatedWarningText(warning, at: CGPoint(x: faceAbottom.size.width/2 + CGFloat(tabWidth), y: CGFloat(width + height)), angle: 0)
                drawRotatedWarningText(warning, at: CGPoint(x: CGFloat(tabWidth + length + width) + faceCtop.size.width/2, y: 0), angle: 180)
                drawRotatedWarningText(warning, at: CGPoint(x: CGFloat(tabWidth + length + width) + faceCbottom.size.width/2, y: CGFloat(width + height)), angle: 0)
            }
        }
        
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        
        docURL = docURL?.appendingPathComponent("\(fileName).pdf")
        
        //Lastly, write your file to the disk.
        
        do {
            try data.write(to: docURL!)
        } catch {
            print("error")
        }
    }
    
    func drawText(_ text: String, at p: CGPoint, withFont font: UIFont) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let c = UIGraphicsGetCurrentContext()!
        c.saveGState()

        // Draw the text
        text.draw(at: p, withAttributes: attributes as [NSAttributedString.Key : Any])
        // Restore the original coordinate system.
        c.restoreGState()
    }
    
    func drawRotatedWarningText(_ text: String, at p: CGPoint, angle: CGFloat) {
        // Draw text centered on the point, rotated by an angle in degrees moving clockwise.
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 16),
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
            self.multiplier = 3.5
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.controlsViewBottomConstraint.constant == 0 {
                UIView.animate(withDuration: 0.0) {
                    self.controlsViewBottomConstraint.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func hideKeyboard() {
        print("Keyboard hidden")
        self.view.endEditing(true)
        view.resignFirstResponder()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.controlsViewBottomConstraint.constant != 0 {
            UIView.animate(withDuration: 0.0) {
                self.controlsViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //BATCH PROCESSING
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let url = urls[0]
        let isSecuredURL = url.startAccessingSecurityScopedResource() == true
        let coordinator = NSFileCoordinator()
        var error: NSError? = nil
        var parseError: NSError? = nil
        coordinator.coordinate(readingItemAt: url, options: [], error: &error) { (url) -> Void in
            _ = urls.compactMap { (url: URL) -> URL? in
                // Create file URL to temporary folder
                var tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
                // Apend filename (name+extension) to URL
                tempURL.appendPathComponent(url.lastPathComponent)
                do {
                    // If file with same name exists remove it (replace file with new one)
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(atPath: tempURL.path)
                    }
                    // Move file from app_id-Inbox to tmp/filename
                    try FileManager.default.moveItem(atPath: url.path, toPath: tempURL.path)
                    
                    let content = try String(contentsOf: tempURL)
                    self.items = parseCSV(content: content, encoding: .utf8, error: &parseError)
                    
                    if let items = items {
                        batchGenerateOutlinesFor(items: items)
                    }
                    
                    return tempURL
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
            }
        }
        if (isSecuredURL) {
            url.stopAccessingSecurityScopedResource()
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func parseCSV (content: String, encoding: String.Encoding, error: NSErrorPointer) -> [(sku:String, length:String, width:String, height:String, asin:String, itemName:String)]? {
        
        // Load the CSV file and parse it
        
        let delimiter = ","
        let content = content
        items = []
        
        let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
        
        for line in lines {
            
            var values:[String] = []
            
            if line != "" {
                
                // For a line with double quotes
                
                // we use NSScanner to perform the parsing
                
                if line.range(of: "\"") != nil {
                    
                    var textToScan:String = line
                    
                    var value:NSString?
                    
                    var textScanner:Scanner = Scanner(string: textToScan)
                    
                    while textScanner.string != "" {
                        
                        if (textScanner.string as NSString).substring(to: 1) == "\"" {
                            
                            textScanner.scanLocation += 1
                            
                            textScanner.scanUpTo("\"", into: &value)
                            
                            textScanner.scanLocation += 1
                            
                        } else {
                            
                            textScanner.scanUpTo(delimiter, into: &value)
                            
                        }
                        
                        // Store the value into the values array
                        
                        values.append(value! as String)
                        
                        // Retrieve the unscanned remainder of the string
                        
                        if textScanner.scanLocation < textScanner.string.count {
                            
                            textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                            
                        } else {
                            
                            textToScan = ""
                            
                        }
                        
                        textScanner = Scanner(string: textToScan)
                        
                    }
                    
                    // For a line without double quotes, we can simply separate the string
                    
                    // by using the delimiter (e.g. comma)
                    
                } else  {
                    
                    values = line.components(separatedBy: delimiter)
                    
                }
                
                // Put the values into the tuple and add it to the items array
                
                let item = (sku: values[0], length: values[1], width: values[2], height: values[3], asin: values[4], itemName: values[5])
                
                items?.append(item)
                
            }
            
        }
        
        return items
    }
    
    class func fromString(string : String) -> UIImage? {
        
        let data = string.data(using: .ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let outputCIImage = filter.outputImage {
                return UIImage(ciImage: outputCIImage)
            }
        }
        return nil
    }
    
}
