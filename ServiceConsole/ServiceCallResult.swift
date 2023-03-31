//
//  ServiceCallResult.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/31.
//

import Foundation

enum ServiceCallResult: Equatable {
    case ready
    case ok([String])
    case error(String)

    static func == (lhs: ServiceCallResult, rhs: ServiceCallResult) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready):
            return true
        case let (.ok(lhsData), .ok(rhsData)):
            return lhsData == rhsData
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
