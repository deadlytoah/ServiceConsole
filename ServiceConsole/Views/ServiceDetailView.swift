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
//  ServiceDetailView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/04/11.
//

import SwiftUI

struct ServiceDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var zmqContext: ZMQContext

    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var errorDetails = ""

    @State private var commands: [Command] = []

    let service: Service

    var body: some View {
        VStack(alignment: .leading) {
            Text(service.description)
                .font(.title3)
            List {
                ForEach(self.commands, id: \.name) { command in
                    NavigationLink(destination: ServiceCallView(service: service, command: command)) {
                        VStack(alignment: .leading) {
                            Text(command.name)
                                .font(.headline)
                            Text(command.description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showingError) {
            Alert(title: Text("Error"), message: Text("\(self.errorMessage) (Details: \(self.errorDetails))"), dismissButton: .default(Text("OK")) {
                self.dismiss()
            })
        }
        .padding()
        .navigationTitle(service.name)
        .task {
            do {
                // Contact the endpoint to create the Service instance.
                let proxy = ProxyOfService(zmqContext: zmqContext.get()!, endpoint: service.endpoint)
                self.commands = try proxy.list()
            } catch let e as SCError {
                errorMessage = "Couldn't list commands for the service."
                errorDetails = e.localizedDescription
                showingError = true
            } catch let e as SCBackendError {
                errorMessage = "Couldn't list commands for the service."
                errorDetails = e.localizedDescription
                showingError = true
            } catch let e {
                errorMessage = "Couldn't list commands for the service."
                errorDetails = e.localizedDescription
                showingError = true
            }
        }
    }

    private func dismiss() {
        // Pop view off navigation stack
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct ServiceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceDetailView(service: Service(name: "email", description: "sends and receives e-mails", endpoint: "tcp://localhost:5555"))
    }
}
