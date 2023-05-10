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
//  AddServiceView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/04/11.
//

import SwiftUI

struct AddServiceView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var zmqContext: ZMQContext
    @EnvironmentObject var serviceStore: ServiceStore

    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var errorDetails = ""

    @State private var endpoint = ""

    var body: some View {
        Form {
            TextField("Endpoint", text: $endpoint)
                .onSubmit(addService)
            Button("Add Service", action: addService)
        }
        .alert(isPresented: $showingError) {
            Alert(title: Text("Error"), message: Text("\(self.errorMessage) (Details: \(self.errorDetails))"), dismissButton: .default(Text("OK")))
        }
        .padding()
        .navigationTitle("Add Service")
    }

    private func dismiss() {
        // Pop view off navigation stack
        self.presentationMode.wrappedValue.dismiss()
    }

    private func addService() {
        do {
            // Contact the endpoint to create the Service instance.
            let proxy = ProxyOfService(zmqContext: zmqContext.get()!, endpoint: endpoint)
            let (name, description) = try proxy.describe()

            let service = Service(name: name, description: description, endpoint: endpoint)

            // Add new service to service store
            try serviceStore.addService(service)
            dismiss()
        } catch let e as SCError {
            errorMessage = "Couldn't add the service."
            errorDetails = e.localizedDescription
            showingError = true
        } catch let e {
            errorMessage = "Couldn't add the service."
            errorDetails = e.localizedDescription
            showingError = true
        }
    }
}

struct AddServiceView_Previews: PreviewProvider {
    static var previews: some View {
        AddServiceView()
            .environmentObject(ZMQContext())
            .environmentObject(ServiceStore())
    }
}
