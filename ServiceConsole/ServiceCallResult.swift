//
//  ServiceCallResult.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/31.
//

import Foundation

enum ServiceCallResult<T> {
    case ready
    case ok(Date, T)
    case error(Date, String)
}
