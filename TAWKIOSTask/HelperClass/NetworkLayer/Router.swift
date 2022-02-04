//
//  Router.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation


enum Router {
    
    case getUserList(body: String)
    case getUserProfile(body: String)

    static let baseURLString = AppConstants.baseURL
    
    private enum HTTPMethod {
        case get
        case post
        case put
        case patch
        case delete
        
        var value: String {
            switch self {
                case .get   : return "GET"
                case .post  : return "POST"
                case .put   : return "PUT"
                case .patch : return "PATCH"
                case .delete: return "DELETE"
            }
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        case .getUserList:
            return .get
        case .getUserProfile:
            return .get
        }
    }
  
    private var endPoint: String {
        switch self {
        case .getUserList:
            return "users?since="
        case .getUserProfile:
            return "users/"
        }
    }
    
    
    func request() throws -> URLRequest {
        var urlString = "\(Router.baseURLString)\(endPoint)"
        
        if method == .get {
            switch self {
            case .getUserList(let body):
                urlString.append(body)
            case .getUserProfile(let body):
                urlString.append(body)
            default:
                print("No value")
            }
        }
//        if method == .delete {
//            switch self {
//            case .deletePost(let body), .deleteComment(let body):
//                urlString.append(body)
//            default:
//                print("No value")
//            }
//        }
        
        print("final url is here=======",urlString)
        
        guard let url = URL(string: urlString) else {
            throw ErrorType.parseUrlFail
        }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: Double.infinity)
        request.httpMethod = method.value
        
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")

        return request
//        if let token = currentUser?.token, token != "" {
//            request.setValue("Bearer \(token)", forHTTPHeaderField:"Authorization")
//        }
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
       /* switch self {
        case .getUserList:
            
            var data = Data()
            var isVideo = false
            
            if (body["post_type"] as? String) == "video" {
                isVideo = true
            }
            
            for (key, value) in body {
                let paramName = key
                
                if value as? String != nil {
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition:form-data; name=\"\(paramName)\"".data(using: .utf8)!)
                    data.append("\r\n\r\n\(value)\r\n".data(using: .utf8)!)
                }
                else if let url = value as? URL {
                    if let d = try? Data(contentsOf: url) {
                        let ext = url.pathExtension
                        data.append("--\(boundary)\r\n".data(using: .utf8)!)
                        data.append("Content-Disposition:form-data; name=\"\(paramName)\"".data(using: .utf8)!)
                        data.append("; filename=\"\(key).\(ext)\"\r\nContent-Type:\(getMimeType(str: ext))\r\n\r\n".data(using: .utf8)!)
                        data.append(d)
                        data.append("\r\n".data(using: .utf8)!)
                    }
                }
                else if let urls = value as? [URL] {
                    for url in urls {
                        if let d = try? Data(contentsOf: url) {
                            let ext = url.pathExtension
                            let fileName = url.lastPathComponent
                            data.append("--\(boundary)\r\n".data(using: .utf8)!)
                            data.append("Content-Disposition:form-data; name=\"\(paramName)\"".data(using: .utf8)!)
                            data.append("; filename=\"\(fileName)\"\r\nContent-Type:\(getMimeType(str: ext))\r\n\r\n".data(using: .utf8)!)
                            data.append(d)
                            data.append("\r\n".data(using: .utf8)!)
                        }
                    }
                }
                else if let d = value as? Data {
                    print("IMAGE ADDED IN REQUEST")
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition:form-data; name=\"\(paramName)\"".data(using: .utf8)!)
                    data.append("; filename=\"\(key).\(isVideo ? "mp4" : "png")\"\r\nContent-Type:\(isVideo ? "video/mp4" : "image/png")\r\n\r\n".data(using: .utf8)!)
                    data.append(d)
                    data.append("\r\n".data(using: .utf8)!)
                } else if let d = value as? [Data] {
                    var i = 0
                    for _d in d {
                        i+=1
                        print("IMAGE ADDED IN REQUEST")
                        data.append("--\(boundary)\r\n".data(using: .utf8)!)
                        data.append("Content-Disposition:form-data; name=\"\(paramName)\"".data(using: .utf8)!)
                        data.append("; filename=\"\(key)_\(i).\(isVideo ? "mp4" : "png")\"\r\nContent-Type:\(isVideo ? "video/mp4" : "image/png")\r\n\r\n".data(using: .utf8)!)
                        data.append(_d)
                        data.append("\r\n".data(using: .utf8)!)
                    }
                }
            }
            data.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = data
            return request
            
        default:
            return request
        } */
    }
    
    func getMimeType(str : String) -> String {
        if str == "mp4" {
            return "video/mp4"
        } else if str == "png" {
            return "image/png"
        } else if str == "pdf" {
            return "application/pdf"
        } else if str == "jpeg" {
            return "image/jpeg"
        } else if str == "jpg" {
            return "image/jpeg"
        } else if str == "doc" {
            return "application/msword"
        } else if str == "docx" {
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        }
        
        return ""
    }
}
