//
//  Request.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import Foundation

struct Request: Hashable {
    var socketAddress: String
    var command: String
    var argumentFields: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(socketAddress)
        hasher.combine(command)
        hasher.combine(argumentFields)
    }

    static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.socketAddress == rhs.socketAddress &&
               lhs.command == rhs.command &&
               lhs.argumentFields == rhs.argumentFields
    }
}
