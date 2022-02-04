//
//  Utilities.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation
import UIKit

class Utilities
{
    static var shared = Utilities()
    
    var notiToastString : ((String) -> ())?
    var notifycheckCamera : (() -> ())?
    var socketConnected : (() -> ())?
    var notifyListUpdate: ((Int) -> ())?
    var redirectNotificationClosure : ((String, Int) -> ())?
    
    
    class func viewController(name:String, onStoryBoared storyboared: String) -> UIViewController
    {
        let sb = UIStoryboard(name: storyboared, bundle: nil)
        return sb.instantiateViewController(withIdentifier: name) as UIViewController
    }
    
    class func showNoDataFoundLabel(tableview:UITableView, strMsg : String) -> Int
     {
         let noDataLabel = UILabel()
         noDataLabel.textAlignment = .center
         noDataLabel.text = strMsg
         noDataLabel.center = tableview.center
         noDataLabel.font = UIFont.systemFont(ofSize: 15)
        noDataLabel.textColor = .darkGray
         tableview.backgroundView = noDataLabel
         
         return 0
     }
    
}
