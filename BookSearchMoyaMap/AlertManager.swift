//
//  AlertManager.swift
//  BookSearchMoyaMap
//
//  Created by 上條蓮太朗 on 2023/05/12.
//  Copyright © 2023 uejo. All rights reserved.
//

import UIKit

class AlertManager {
    
    static func generateAlert(title: String?,
                              message: String,
                              cancelText: String,
                              doneText: String?,
                              isDelete: Bool = false,
                              cancelCompletion: (() -> Void)?,
                              doneCompletion: (() -> Void)?) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let _doneText = doneText {
            let style: UIAlertAction.Style = isDelete ? .destructive : .default
            let doneAction = UIAlertAction(title: _doneText, style: style, handler: { (action) -> Void in
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
                            title: String? = nil,
                            message: String,
                            cancelText: String,
                            doneText: String?,
                            isDelete: Bool = false,
                            cancelCompletion: (() -> Void)?,
                            doneCompletion: (() -> Void)?) {
        
        let alert = AlertManager.generateAlert(title: title,
                                               message: message,
                                               cancelText: cancelText,
                                               doneText: doneText,
                                               isDelete: isDelete,
                                               cancelCompletion: cancelCompletion,
                                               doneCompletion: doneCompletion)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showErrorAlert(_ viewController: UIViewController, error: Error) {
        let message = error.localizedDescription
        let alert = AlertManager.generateAlert(title: "エラー",
                                               message: message,
                                               cancelText: "閉じる",
                                               doneText: nil,
                                               cancelCompletion: nil,
                                               doneCompletion: nil)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
