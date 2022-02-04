//
//  ErrorType.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation



enum ErrorType: Error, LocalizedError {
    case noInternetConnection
    case parseResponseFail
    case parseUrlFail
    case notFound
    case validationError
    case serverError
    case wrongOTP
    case defaultError
    
    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet Connection"
        case .parseUrlFail:
            return "Cannot initial URL object."
        case .notFound:
            return "Not Found"
        case .validationError:
            return "Validation Errors"
        case .serverError:
            return "Internal Server Error"
        case .defaultError:
            return "Something went wrong."
        case .parseResponseFail:
            return "Cannot parse response."
        case .wrongOTP:
            return "Your have enter wrong OTP!"
        }
    }
}
