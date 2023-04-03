//
//  SCError.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import Foundation
import SwiftyZeroMQ

enum SCBackendError: Error {
    case unknownCommand(String)
    case uncategorised(String)

    var message: String {
        get {
            switch self {
            case .unknownCommand(let message):
                return message
            case .uncategorised(let message):
                return message
            }
        }
    }

    init(code: String, message: String) {
        switch code {
        case "ERROR_UNKNOWN_COMMAND":
            self = .unknownCommand(message)
        default:
            self = .uncategorised(message)
        }
    }
}

enum SCError: Error {
    case json([String: Any])
    case proto(String, String)
    case timeout(String)
    case uuid(String)
    case zmq(String, SwiftyZeroMQ.ZeroMQError)
}
