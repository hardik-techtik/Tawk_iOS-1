//
//  GlobalClass.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation

import UIKit

let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
let SCREEN_WIDTH        = UIScreen.main.bounds.size.width
let SCREEN_SIZE         = UIScreen.main.bounds.size

struct Messages {
    static let noInternetConnection = "No internet connection"
    static let somethingwentwrong   = "Something went wrong"
    static let success              = "Success"
    static let BTN_YES              = "Yes"
    static let BTN_NO               = "No"
    static let BTN_OK               = "OK"
    static let BTN_CANCEL           = "Cancel"
    static let BTN_DELETE           = "Delete"
}

struct AppConstants {
    static let APP_NAME = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "iOSDevTest"
    static let AppStore_URL = ""
    static let deviceType           = "ios"
    static let baseURL              = "https://api.github.com/"
}

//MARK: - GLOBAL METHODS -

var objAppDelegate    : AppDelegate!

func showLoader(){
    hideLoader()
    DispatchQueue.main.async {
        if let w = SceneDelegate.shared?.window {
            let loaderContainer = UIView(frame: w.bounds)
            loaderContainer.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            loaderContainer.tag = Int.max
            let w_h : CGFloat = 100.0
            let indicator = UIActivityIndicatorView(frame: CGRect(x: (SCREEN_WIDTH - w_h)/2, y: (SCREEN_HEIGHT - w_h)/2, width: w_h, height: w_h))
            indicator.color = UIColor.white//.withAlphaComponent(0.4)
            indicator.style = UIActivityIndicatorView.Style.large
            indicator.startAnimating()
            loaderContainer.addSubview(indicator)
            w.addSubview(loaderContainer)
        }
    }
}

func hideLoader() {
    DispatchQueue.main.async {
        if let w = SceneDelegate.shared?.window {
            if let loader = w.viewWithTag(Int.max) {
                loader.removeFromSuperview()
            }
        }
    }
}


func showMessage(text:String)
{
    if Utilities.shared.notiToastString != nil {
        Utilities.shared.notiToastString!(text)
    }
}

extension UIViewController {
    
    func showToastMessage(message : String) {
        
        let font = UIFont.systemFont(ofSize: 17)
        
        let width = self.view.frame.size.width - 40//self.view.frame.size.width - 40
        
        let height = heightForViewlabel(text: message, font: font, width: width)
        print("get cell height ----------------\(height)")
        
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.size.height-60, width:width , height: CGFloat(message.count + 10)))
        
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 17)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = CGFloat(message.count + 10) / 2;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    func heightForViewlabel(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
}

extension FileManager {

    static func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
 }
}
