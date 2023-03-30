//
//  SCError.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import Foundation

enum SCError: Error {
    case backend(String, String)
    case json([String: Any])
    case proto(String, String)
    case timeout(String)
    case uuid(String)
}
