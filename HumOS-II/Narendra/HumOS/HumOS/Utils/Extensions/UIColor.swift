//
//  UIColor.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func randomColor() -> String{
        
        var color = "#3CA4EA"
        let k: Int = random() % 6;
        switch k {
        case 1:
            color = "#AC3BED"
            break
        case 2:
            color = "#26D8A5"
            break
        case 3:
            color = "#FCDE03"
            break
        case 4:
            color = "#EF3D3C"
            break
        case 5:
            color = "#FF8229"
            break
        case 6:
            color = "#3CA4EA"
            break
        default :
            color = "#3CA4EA"
            
        }
        return color
    }
}