//
//  ContentView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/29.
//

import SwiftUI

struct ContentView: View {
    @State private var socketAddress: String = ""
    @State private var command: String = ""
    @State private var argumentFields: [String] = [""]

    var body: some View {
        NavigationView {
            VStack {
                TextField("Socket Address", text: $socketAddress)
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
                        if self.argumentFields.count > 1 {
                            self.argumentFields.removeLast()
                        }
                    }) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 12))
                    }
                }

                NavigationLink("Invoke", value: Request(socketAddress: self.socketAddress, command: self.command, argumentFields: self.argumentFields))
            }
            .padding()
            .navigationTitle("Remote Method")
            .navigationDestination(for: Request.self) { request in
                ResultView(request: request)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
