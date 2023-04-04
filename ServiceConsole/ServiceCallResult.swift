//
//  ServiceCallResult.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/31.
//

import Foundation

enum ServiceCallResult {
    case ready
    case ok(Date, [String])
    case error(Date, String)
}
