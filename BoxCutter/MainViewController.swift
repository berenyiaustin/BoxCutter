//
//  ViewController.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/1/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit
import PDFKit
import MobileCoreServices

class MainViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UIDocumentPickerDelegate {

    let theme = Theme.theme1
    let defaults = UserDefaults.standard
    
    public var isInches = true
    var unit = 72.00
    var multiplier = 2.5
    
    var fileName = "MC"
    
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
        
        //BATCH PROCESSING TEST
        
        
        //MAIN
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
        scrollView.delegate = self
        
        scrollView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,UIView.AutoresizingMask.flexibleHeight]
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 50
        scrollView.zoomScale = 0.25
        
        UIView.animate(withDuration: 0.5, delay: 2.5, options: .curveEaseOut, animations: {
            
        }, completion: nil)
        
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
        scrollView.contentSize = CGSize(width: 5000, height: 5000)
    }
    
    @IBAction func uploadCSVFile(_ sender: Any) {
        let types: [String] = [kUTTypeCommaSeparatedText as String]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
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
            
            if let fileNameString = fileNameTextField.text {
                fileName = fileNameString
                //Append suffix if it exists
                if let suffix = self.defaults.string(forKey: "fileNameSuffix") {
                    fileName.append(" \(suffix)")
                }
                drawBoxesWithinPDFView(saveToDocumentsWithFileName: "\(fileName).pdf")
            } else {
                drawBoxesWithinPDFView(saveToDocumentsWithFileName: "\(fileName).pdf")
            }
            
            // Create a PDFDocument object and set it as PDFView's document to load the document in that view.
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = (documentsDirectory as NSString).appendingPathComponent("\(fileName).pdf") as String
            let url = NSURL(fileURLWithPath: filePath)
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func drawBoxesWithinPDFView(saveToDocumentsWithFileName fileName: String) {
        
        //Dimension Calculations
        if let lengthNumber = lengthTextField.text {
            length = Double(lengthNumber)! * unit
        }
        if let widthNumber = widthTextField.text {
            width = Double(widthNumber)! * unit
        }
        if let heightNumber = heightTextField.text {
            height = Double(heightNumber)! * unit
        }
        
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
            
            if let warning = self.defaults.string(forKey: "cutWarningText") {
                drawRotatedText(warning, at: CGPoint(x: faceAtop.size.width/2 + 72, y: 0), angle: 180)
                drawRotatedText(warning, at: CGPoint(x: faceAbottom.size.width/2 + 72, y: CGFloat(width + height)), angle: 0)
                drawRotatedText(warning, at: CGPoint(x: 72 + CGFloat(length + width) + faceCtop.size.width/2, y: 0), angle: 180)
                drawRotatedText(warning, at: CGPoint(x: 72 + CGFloat(length + width) + faceCbottom.size.width/2, y: CGFloat(width + height)), angle: 0)
            }
        }
        
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        
        docURL = docURL?.appendingPathComponent(fileName)
        
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
    
    @IBAction func fileNameEditingChanged(_ sender: Any) {
        
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
        // you get from the urls parameter the urls from the files selected
        
        print(urls[0].absoluteString)
        
        if let string = readDataFrom(file: urls[0].absoluteString) {
            if let items = parseCSV(content: string, encoding: String.Encoding.utf8, error: &error) {
                self.length = Double(items[0].length)!
                self.width = Double(items[0].length)!
                self.height = Double(items[0].width)!
                
                print(self.length)
            }
        }
    }
    
    func readDataFrom(file:String?)-> String! {
        
        if let filepath = file {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                print(error)
            }
        } else {
            
        }
        return nil
    }
    
    func parseCSV (content: String, encoding: String.Encoding, error: NSErrorPointer) -> [(sku:String, length:String, width: String, height:String)]? {
        
        // Load the CSV file and parse it
        
        let delimiter = ","
        let content = content
        var items:[(sku:String, length:String, width: String, height:String)]?
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
                
                let item = (sku: values[0], length: values[1], width: values[2], height: values[3])
                
                items?.append(item)
                
            }
            
        }
        
        return items
    }
    
}