//
//  GeneralResponseModel.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation

struct GeneralResponse: Codable {
    var message: String?
    var error: String?
    var status_code: Int?
    var response: String?
}
