//
//  BoxCutterTextField.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/10/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit

class BoxCutterTextField: UITextField {
    
    private var updatedClearImage = false

    let theme = Theme.theme1
    
    required init?(coder aDecoder: NSCoder){
        
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 8
        leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.height + 10))
        self.addTarget(self, action: #selector(hideKeyboard), for: .editingDidEnd)
        self.layer.borderWidth = 2
        self.layer.borderColor = theme.lightGray.cgColor
        self.borderStyle = .none
        self.keyboardAppearance = .dark
        self.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        self.textColor = .white
        self.tintColor = theme.mainColor
        if let placeholder = self.placeholder {
            self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : theme.lightGray])
        }
        
        self.clearButtonMode = .always
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
    }
    
    @objc func hideKeyboard(){
        resignFirstResponder()
    }
    
    private func tintClearImage() {
        if updatedClearImage { return }
        
        if let button = self.value(forKey: "clearButton") as? UIButton,
            let image = button.image(for: .highlighted)?.withRenderingMode(.alwaysTemplate) {
            button.setImage(image, for: .normal)
            button.setImage(image, for: .highlighted)
            button.tintColor = .white
            
            updatedClearImage = true
        }
    }
}

public extension UITextField {
    
    func shake(count : Float = 2, for duration : TimeInterval = 0.15, withTranslation translation : Float = 8) {
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: CGFloat(-translation), y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: CGFloat(translation), y: self.center.y))
        layer.add(animation, forKey: "shake")
    }
}
