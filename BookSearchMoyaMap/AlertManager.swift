//
//  AlertManager.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/12.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit

class AlertManager {
    
    static func generateAlert(message: String,
                              cancelText: String,
                              doneText: String?,
                              cancelCompletion: (() -> Void)?,
                              doneCompletion: (() -> Void)?) -> UIAlertController {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if let _doneText = doneText {
            let doneAction = UIAlertAction(title: _doneText, style: .default, handler: { (action) -> Void in
                doneCompletion?()
            })
            alert.addAction(doneAction)
        }
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: { (action) -> Void in
            cancelCompletion?()
        })
        alert.addAction(cancelAction)
        return alert
    }
    
    static func showAlertIn(_ viewController: UIViewController,
                            message: String,
                            cancelText: String,
                            doneText: String?,
                            cancelCompletion: (() -> Void)?,
                            doneCompletion: (() -> Void)?) {
        
        let alert = AlertManager.generateAlert(message: message, cancelText: cancelText, doneText: doneText, cancelCompletion: cancelCompletion, doneCompletion: doneCompletion)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
