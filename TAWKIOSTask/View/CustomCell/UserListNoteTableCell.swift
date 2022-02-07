//
//  UserListNoteTableCell.swift
//  TAWKIOSTask
//
//  Created by Hardik on 07/02/22.
//

import Foundation
import UIKit
import CoreData

class UserListNoteTableCell: UITableViewCell {

    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblDetails : UILabel!
    @IBOutlet var backView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.dropShadow()
        backView.layer.cornerRadius = 10
        imgUser.layer.cornerRadius = imgUser.frame.size.height / 2
        imgUser.layer.masksToBounds = true
    }
    
    func configureCell(objUser:UserListModel,index:Int) {
        self.lblName.text = objUser.login
        self.lblDetails.text = objUser.node_id
        if objUser.avatar_url == nil {
            DispatchQueue.main.async { /// execute on main thread
                self.imgUser.image = UIImage(data: objUser.imgData! as Data)
            }
        }else {
            downloadImageAsync(strURL: objUser.avatar_url ?? "")
        }
    }
    
    func downloadImageAsync(strURL:String) {
        if let url = URL(string: strURL) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async { /// execute on main thread
                    self.imgUser.image = UIImage(data: data)
                }
            }
            task.resume()
        }else {
            self.imgUser.image = UIImage(named: "ic_user")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
