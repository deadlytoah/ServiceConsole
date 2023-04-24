//
//  Request.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import Foundation

struct Request: Hashable {
    var command: String
    var arguments: [String]

    func hash(into hasher: inout Hasher) {
        hasher.combine(command)
        hasher.combine(arguments)
    }

    static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.command == rhs.command &&
               lhs.arguments == rhs.arguments
    }
}
