/*
 * GUI Console for IPC Services
 * Copyright (C) 2023  Hee Shin
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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

    var localizedDescription: String {
        get {
            switch self {
            case .unknownCommand(let message):
                return "Unknown command: \(message)"
            case .uncategorised(let message):
                return "Uncategorised error: \(message)"
            }
        }
    }
}

enum SCError: Error {
    case json([String: Any])
    case proto(String, String)
    case store(String)
    case timeout(String)
    case uuid(String)
    case zmq(String, SwiftyZeroMQ.ZeroMQError)

    var localizedDescription: String {
        get {
            switch self {
            case .json(let json):
                return "JSON error: \(json)"
            case .proto(let command, let message):
                return "Protocol error while invoking [\(command)]: \(message)"
            case .store(let message):
                return "Data store error: \(message)"
            case .timeout(let message):
                return "Timeout error: \(message)"
            case .uuid(let message):
                return "UUID error: \(message)"
            case .zmq(let command, let message):
                return "ZMQ error while invoking [\(command)]: \(message)"
            }
        }
    }
}
