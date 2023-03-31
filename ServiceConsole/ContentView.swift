//
//  ContentView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var zmqContext: ZMQContext
    @State var serviceController: ServiceController? = nil

    @State private var port: String = ""
    @State private var command: String = ""
    @State private var argumentFields: [String] = []

    @State var result: ServiceCallResult = .ready

    var body: some View {
        NavigationSplitView {
            VStack {
                TextField("Port", text: $port)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Command", text: $command)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                ForEach(argumentFields.indices, id: \.self) { index in
                    TextField("Argument \(index + 1)", text: self.$argumentFields[index])
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack {
                    Button(action: {
                        self.argumentFields.append("")
                    }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 12))
                    }
                    Button(action: {
                        if self.argumentFields.count > 0 {
                            self.argumentFields.removeLast()
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 12))
                    }
                }

                Button("Invoke") {
                    let request = Request(socketAddress: "tcp://127.0.0.1:\(self.port)", command: self.command, arguments: self.argumentFields)
                    self.result = self.serviceController!.invokeRemoteFunction(request)
                }
            }
            .padding()
            .navigationTitle("Remote Method")
        } detail: {
            ResultView(result: self.$result)
        }
        .onAppear {
            self.serviceController = ServiceController(zmqContext: self.zmqContext)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ZMQContext())
    }
}
