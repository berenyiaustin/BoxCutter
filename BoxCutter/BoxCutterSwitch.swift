//
//  BoxCutterSwitch.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/10/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit

class BoxCutterSwitch: UISwitch {
    
    let theme = Theme.theme1

    required init?(coder aDecoder: NSCoder){
        
        super.init(coder: aDecoder)
        
        self.thumbTintColor = theme.mainColor
        self.tintColor = theme.lightGray
        self.onTintColor = theme.lightGray
        self.backgroundColor = theme.lightGray
        self.layer.cornerRadius = self.frame.size.height/2
        
    }

}
