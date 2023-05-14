//
//  IndicatorManager.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/12.
//  Copyright © 2023 uejo. All rights reserved.
//

import Foundation
import PKHUD

class IndicatorManager {
    
    static func show() {
        HUD.show(.progress)
    }
    
    static func hide() {
        HUD.hide()
    }
}
