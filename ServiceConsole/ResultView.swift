//
//  ResultView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import SwiftUI
import SwiftyZeroMQ

let SOCKET_TIMEOUT: TimeInterval = 200.0

struct ResultView: View {
    @EnvironmentObject var zmqContext: ZMQContext

    let request: Request
    @State var result: [String]? = nil
    @State var error: String? = nil

    var body: some View {
        VStack {
            if let result = result {
                Text("Result:")
                    .font(.headline)
                    .padding(.bottom)

                List(result, id: \.self) {
                    Text($0)
                }
            } else if let error = error {
                Text("Error:")
                    .font(.headline)
                    .padding(.bottom)

                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Result")
        .onAppear(perform: self.invokeRemoteFunction)
    }

    func invokeRemoteFunction() {
        if let zcontext = self.zmqContext.get() {
            do {
                self.result = try invokeRemoteFunctionImpl(zcontext, self.request.socketAddress, self.request.command, self.request.arguments)
                self.error = nil
            } catch {
                self.result = nil
                self.error = "Couldn't call the remote function."
            }
        } else {
            self.result = nil
            self.error = "App failed to initialise.  Please restart."
        }
    }

    private func invokeRemoteFunctionImpl(_ context: SwiftyZeroMQ.Context, _ address: String, _ command: String, _ arguments: [String]) throws -> [String] {
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
                throw SCError.proto(command, "Error in the contract of Result")
            }
        } else {
            throw SCError.timeout(command)
        }
    }
}

//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}
