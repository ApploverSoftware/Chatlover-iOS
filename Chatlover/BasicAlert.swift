//
//  BasicAlert.swift
//  Chatlover
//
//  Created by Mac on 07.11.2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit

class BasicAlert {
    class func showInfoAlert(with message: Error, completionHandler: (() -> Void)? = nil) {
        var messageText = ""
        if let apiError = message as? APIError {
            messageText = apiError.localizedDescription
        } else {
            messageText = message.localizedDescription
        }
        
        let alertController = UIAlertController(title: "", message: messageText, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("_basicAlertOkButton", comment: ""), style: .default, handler: { _ in
            completionHandler?()
        }))
        show(alertController)
    }
    
    class func show(_ alert: UIViewController) {
        UIApplication.shared.keyWindow!.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
