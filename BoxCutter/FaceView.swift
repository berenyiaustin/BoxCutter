//
//  FaceView.swift
//  BoxCutter
//
//  Created by Austin Berenyi on 4/1/19.
//  Copyright © 2019 Austin Berenyi. All rights reserved.
//

import UIKit

class FaceView: UIView {
    
    let theme = Theme.theme1

    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }

    func didLoad(){
        backgroundColor = theme.darkGray
        layer.borderColor = theme.grapeFruit.cgColor
        layer.borderWidth = 2
    }

}
