//
//  ServiceController.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/31.
//

import Foundation
import SwiftyZeroMQ

struct ServiceController {
    let zmqContext: ZMQContext

    func invokeRemoteFunction(_ request: Request) -> ServiceCallResult {
        if let zcontext = self.zmqContext.get() {
            do {
                return .ok(try invokeRemoteFunctionImpl(zcontext, request.socketAddress, request.command, request.arguments))
            } catch SCError.timeout(let command) {
                return .error("Calling the remote command [\(command)] timed out.")
            } catch SCError.proto(let command, let message) {
                return .error("Contract violation while running [\(command)]: \(message)")
            } catch SCError.backend(let command, let message) {
                return .error("Backend says [\(command)]: \(message)")
            } catch SCError.zmq(let command, let error) {
                return .error("Communications failed [\(command)]: \(error.description)")
            } catch {
                return .error("Couldn't call the remote function.")
            }
        } else {
            return .error("App failed to initialise.  Please restart.")
        }
    }

    private func invokeRemoteFunctionImpl(_ context: SwiftyZeroMQ.Context, _ address: String, _ command: String, _ arguments: [String]) throws -> [String] {
        do {
            let socket = try context.socket(.request)
            try socket.connect(address)

            // Send the command to the backend
            var commands = [command]
            commands.append(contentsOf: arguments)
            try socket.sendMultipart(parts: commands.map { $0.data(using: .utf8)! })

            let poller = SwiftyZeroMQ.Poller()
            try poller.register(socket: socket, flags: .pollIn)
            let events = try poller.poll(timeout: SOCKET_TIMEOUT)
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
                } else if result == "ERROR" && response.count > 1 {
                    if let message = String(data: response[1], encoding: .utf8) {
                        throw SCError.backend(command, message)
                    } else {
                        throw SCError.backend(command, "error in backend (error message was not in utf8)")
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
