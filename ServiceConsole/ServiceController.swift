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

    let DEFAULT_TIMEOUT = 300.0

    func getMetadata(_ request: Request) -> [String:Any]? {
        let result = self.invokeRemoteFunction(Request(socketAddress: request.socketAddress, command: "metadata", arguments: [request.command]), DEFAULT_TIMEOUT)
        switch result {
        case .ok(_, let response):
            if response.count > 0 {
                let jsonString = response[0]
                let jsonData = jsonString.data(using: .utf8)!
                do {
                    return try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any]
                } catch {
                    return nil
                }
            } else {
                return nil
            }
        default:
            break
        }
        return nil
    }

    func invokeRemoteFunction(_ request: Request, _ timeout: TimeInterval) -> ServiceCallResult {
        if let zcontext = self.zmqContext.get() {
            do {
                return .ok(Date(), try invokeRemoteFunctionImpl(zcontext, request.socketAddress, request.command, request.arguments, timeout))
            } catch SCError.timeout(let command) {
                return .error(Date(), "Calling the remote command [\(command)] timed out.")
            } catch SCError.proto(let command, let message) {
                return .error(Date(), "Contract violation while running [\(command)]: \(message)")
            } catch let error as SCBackendError {
                return .error(Date(), "Backend says: \(error.message)")
            } catch SCError.zmq(let command, let error) {
                return .error(Date(), "Communications failed [\(command)]: \(error.description)")
            } catch {
                return .error(Date(), "Couldn't call the remote function.")
            }
        } else {
            return .error(Date(), "App failed to initialise.  Please restart.")
        }
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
