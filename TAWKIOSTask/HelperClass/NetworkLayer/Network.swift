//
//  Network.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation

class Network {
    static let shared = Network()
    
    private let config: URLSessionConfiguration
    private let session: URLSession
    typealias completionHandler = (_ success : Data?, _ error : Any?) -> ()
    
    private init() {
        config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    static func getMethod(requestURL: String, handler: @escaping  completionHandler)  {
        

        //if Reachability.{
            
            guard let serviceURL = URL(string: requestURL) else {
                return
            }
            
            var request = URLRequest(url: serviceURL)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    if let data = data {
                        handler(data, nil)
                    }
                }else{
                    handler(nil, error)
                }
            }.resume()
//        }else{
//            handler(nil, nil)
//            showMessage(text: Messages.noInternetConnection)
//        }
    }
    
    
    func request<T: Decodable>(router: Router, completion: @escaping (Result<T, ErrorType>) -> ()) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        do {
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            let task = try URLSession.shared.dataTask(with: router.request()) { (data, urlResponse, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        completion(Result.failure(.noInternetConnection))
                        showMessage(text: Messages.noInternetConnection)
                        NotificationCenter.default.post(name: Notification.Name("InternetConnectionError"), object: nil, userInfo: nil)
                        return
                    }else{
                        dispatchGroup.leave()
                        if data != nil {
                            self.printResult(result: data!)
                        }else{
                            showMessage(text: Messages.somethingwentwrong)
                        }
                    }
                    
                    dispatchGroup.notify(queue: DispatchQueue.main) {
                        print("Task execution is completed")
                    }
                    
                    guard let statusCode = urlResponse?.getStatusCode(), (200...299).contains(statusCode) else {
                        let errorType: ErrorType
                        
                        switch urlResponse?.getStatusCode() {
                        case 401, 403:
//                            if !isOnLogin {
//                                hideLoader()
//                                self.showAlertUnAuthrisedUser(nil)
//                            }
                            errorType = .notFound
                            return
                        case 404:
                            errorType = .notFound
                        case 422:
                            errorType = .validationError
                        case 417:
                            errorType = .wrongOTP
                        case 500:
                            errorType = .serverError
                        default:
                            errorType = .defaultError
                        }
                        
                        if let d = data {
                            self.displayErrorMessage(result: d)
                        }else{
                            print(errorType.localizedDescription)
                            showMessage(text: Messages.somethingwentwrong)
                        }
                        completion(Result.failure(errorType))
                        return
                    }
                    
                    guard let data = data else {
                        completion(Result.failure(.defaultError))
                        return
                    }
                    
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        completion(Result.success(result))
                    } catch _ {
                        completion(Result.failure(.parseResponseFail))
                    }
                }
            }
            task.resume()
            
        } catch _ {
            completion(Result.failure(.defaultError))
        }
        }else{
            print("Internet Connection not Available!")
            completion(Result.failure(.noInternetConnection))
            showMessage(text: Messages.noInternetConnection)
            NotificationCenter.default.post(name: Notification.Name("InternetConnectionError"), object: nil, userInfo: nil)
        }
    }
    
//    func showAlertUnAuthrisedUser(_ message : String?) {
//        if let vc = AppDelegate.window?.rootViewController {
//            vc.showPopUp(message: message ?? Messages.SESSIONTIMEOUT, options: [Messages.BTN_OK]) { (_) in
//                SocketRouter.shared.disconnect()
//                currentUser?.clearFromDefault()
//                if !isOnLogin {
//                    DELEGATE.checkRedirection()
//                }
//            }
//        }
//    }
    
    private func printResult(result: Data){
        hideLoader()
        do{
//            let response = try JSONDecoder().decode(GeneralResponse.self, from: result)
//            if response.status_code == 403 || response.status_code == 401 {
//                self.showAlertUnAuthrisedUser(response.message ?? nil)
//            }
            parse(json: result)
        } catch let parsingError {
            print("Error", parsingError.localizedDescription)
            showMessage(text: Messages.somethingwentwrong)//Messages.somethingwentwrong)
        }
    }
    func parse(json: Data) {
        let decoder = JSONDecoder()

        if let jsonPetitions = try? decoder.decode(UserListModel.self, from: json) {
            print(jsonPetitions)
            
        }
    }
    private func displayErrorMessage(result: Data){
        hideLoader()
        do {
            let response = try JSONDecoder().decode(GeneralResponse.self, from: result)
            showMessage(text: response.message ?? Messages.somethingwentwrong)
        } catch let parsingError {
            print("Error", parsingError.localizedDescription)
            showMessage(text: Messages.somethingwentwrong)//Messages.somethingwentwrong)
        }
    }
}

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}


import SystemConfiguration

public class Reachability {

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        /* Only Working for WIFI
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired

        return isReachable && !needsConnection
        */

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}
