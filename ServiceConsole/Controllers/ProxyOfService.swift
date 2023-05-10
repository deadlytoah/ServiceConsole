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
//  ProxyOfService.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/04/15.
//

import Foundation
import SwiftyZeroMQ

struct ProxyOfService {
    let DEFAULT_TIMEOUT = 300.0

    let serviceController: ServiceController

    init(zmqContext: SwiftyZeroMQ.Context, endpoint: String) {
        self.serviceController = ServiceController(zmqContext: zmqContext, endpoint: endpoint)
    }

    func describe() throws -> (String, String) {
        let request = Request(command: "describe", arguments: [])
        let metadata = try self.serviceController.getMetadata(call: request.command, timeout: DEFAULT_TIMEOUT)
        let response = try self.serviceController.invokeRemoteFunction(request, metadata["timeout"] as? TimeInterval ?? DEFAULT_TIMEOUT)
        return (response[0], response[1])
    }

    func list() throws -> [Command] {
        let request = Request(command: "list", arguments: [])
        let metadata = try self.serviceController.getMetadata(call: request.command, timeout: DEFAULT_TIMEOUT)
        let commands = try self.serviceController.invokeRemoteFunction(request, metadata["timeout"] as? TimeInterval ?? DEFAULT_TIMEOUT)
        let response = try self.serviceController.getMetadata(calls: commands, timeout: DEFAULT_TIMEOUT)
        return response.map { Command(name: $0["name"] as! String, description: $0["description"] as? String ?? "") }
    }

    func invoke(command: String, arguments: [String]) throws -> [String] {
        let request = Request(command: command, arguments: arguments)
        let metadata = try self.serviceController.getMetadata(call: request.command, timeout: DEFAULT_TIMEOUT)
        return try self.serviceController.invokeRemoteFunction(request, metadata["timeout"] as? TimeInterval ?? DEFAULT_TIMEOUT)
    }
}
