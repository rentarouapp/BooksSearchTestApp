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
    
    static func showIndicator() {
        HUD.show(.progress)
    }
    
    static func completeIndicator() {
        HUD.flash(.success, delay: 1.0)
    }
}
