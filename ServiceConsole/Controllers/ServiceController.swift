//
//  ServiceController.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/31.
//

import Foundation
import SwiftyZeroMQ

class ServiceController {
    let zmqContext: SwiftyZeroMQ.Context
    let endpoint: String

    init(zmqContext: SwiftyZeroMQ.Context, endpoint: String) {
        self.zmqContext = zmqContext
        self.endpoint = endpoint
    }

    func getMetadata(call: String, timeout: TimeInterval) throws -> [String: Any] {
        let response = try self.invokeRemoteFunction(Request(command: "metadata", arguments: [call]), timeout)
        if response.count > 0 {
            return try Self.deserialiseMetadata(response[0])
        } else {
            throw SCError.proto("metadata", "No metadata returned.")
        }
    }

    func getMetadata(calls: [String], timeout: TimeInterval) throws -> [[String: Any]] {
        let response = try self.invokeRemoteFunction(Request(command: "metadata", arguments: calls), timeout)
        return try response.map { try Self.deserialiseMetadata($0) }
    }

    private static func deserialiseMetadata(_ jsonString: String) throws -> [String: Any] {
        do {
            let jsonData = jsonString.data(using: .utf8)!
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let metadata = jsonObject as? [String:Any] {
                return metadata
            } else {
                throw SCError.proto("metadata", "Metadata is not a dictionary.")
            }
        } catch {
            throw SCError.proto("metadata", "Metadata is not valid JSON.")
        }
    }

    func invokeRemoteFunction(_ request: Request, _ timeout: TimeInterval) throws -> [String] {
        return try self.invokeRemoteFunctionImpl(self.zmqContext, self.endpoint, request.command, request.arguments, timeout)
    }

    private func invokeRemoteFunctionImpl(_ context: SwiftyZeroMQ.Context, _ address: String, _ command: String, _ arguments: [String], _ timeout: TimeInterval) throws -> [String] {
        do {
            let socket = try context.socket(.request)
            try socket.connect(address)

            // Send the command to the backend
            var commands = [command]
            commands.append(contentsOf: arguments)
            try socket.sendMultipart(parts: commands.map { $0.data(using: .utf8)! })

            let poller = SwiftyZeroMQ.Poller()
            try poller.register(socket: socket, flags: .pollIn)
            let events = try poller.poll(timeout: timeout)
            if events[socket]!.contains(.pollIn) {
                let response = try socket.recvMultipart()
                let result = String(data: response[0], encoding: .utf8)

                if result == "OK" {
                    return Array(response.dropFirst().map {
                        if let string = String(data: $0, encoding: .utf8) {
                            return string
                        } else {
                            return "binary data is not encodable in utf-8"
                        }
                    })
                } else if result == "ERROR" && response.count > 2 {
                    if let code = String(data: response[1], encoding: .utf8) {
                        let message: String
                        if let m = String(data: response[2], encoding: .utf8) {
                            message = m
                        } else {
                            message = "error in backend (error message was not in utf8)"
                        }
                        throw SCBackendError(code: code, message: message)
                    } else {
                        throw SCError.proto(command, "error in the contract of Result (error code)")
                    }
                } else {
                    throw SCError.proto(command, "error in the contract of Result")
                }
            } else {
                throw SCError.timeout(command)
            }
        } catch let error as SwiftyZeroMQ.ZeroMQError {
            throw SCError.zmq(command, error)
        }
    }
}
