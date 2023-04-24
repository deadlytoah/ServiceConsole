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
