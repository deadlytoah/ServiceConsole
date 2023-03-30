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
    @State private var result: [String]?
    @State private var error: String?
    @State private var showingResultView = false

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

                NavigationLink("Invoke", value: "result")
            }
            .padding()
            .navigationTitle("Remote Method")
            .navigationDestination(isPresented: $showingResultView) {
                ResultView(result: result, error: error)
            }
        }
    }

    private func invokeRemoteMethod() {
        // TODO: Implement the remote method call

        // For now, just show a dummy result or error
        if command == "hello" {
            result = ["Hello, World!"]
            error = nil
        } else {
            result = nil
            error = "Unknown command: \(command)"
        }

        showingResultView = true
    }
}

struct ResultView: View {
    let result: [String]?
    let error: String?

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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
