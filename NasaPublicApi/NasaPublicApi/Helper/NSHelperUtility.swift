//
//  NSHelperUtility.swift
//  NasaPublicApi
//
//  Created by Chandan Singh on 24/07/22.
//

import Foundation
import UIKit

extension Date {
    func stringDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}

extension String {
    func formattedStringDate(with date: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let dateObj = dateFormatter.date(from: self) {
            return dateFormatter.string(from: dateObj)
        }
        return nil
    }
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
}

extension UIImageView {
    public func imageFromURL(urlString: String, onCompletion: @escaping (()->Void))  {
        self.image = nil
        let networkService = NSNetwork()
        let url = URL(string: urlString)
        guard let request = networkService.createRequest(url: url) else {
            return
        }
        networkService.loadData(using: request) { [weak self] (data, response, error) in
            guard let `self` = self else { return }
            
            if let errorRef = error {
                debugPrint(errorRef)
                onCompletion()
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                guard let dataRef = data else {
                    debugPrint("no data in imageURL")
                    onCompletion()
                    return
                }
                let image = UIImage(data: dataRef)
                self.image = image
                onCompletion()
            })
        }
    }
    
    public func estimatedHeight() -> CGFloat {
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
 
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return scaledHeight
        }
        return 0.0
    }
}

extension UIViewController {
    func presentAlert(withTitle title: String, message : String, actions : KeyValuePairs<String, UIAlertAction.Style>, completionHandler: ((UIAlertAction) -> ())? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            let action = UIAlertAction(title: action.key, style: action.value) { action in
                if completionHandler != nil {
                    completionHandler!(action)
                }
            }
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
