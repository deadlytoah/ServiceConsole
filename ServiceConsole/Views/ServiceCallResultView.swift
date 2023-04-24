//
//  ServiceCallResultView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import SwiftUI
import SwiftyZeroMQ

struct ServiceCallResponse {
    let date: Date
    let rows: [String]
}

struct ServiceCallResultView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var zmqContext: ZMQContext

    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var errorDetails = ""

    @State private var response: ServiceCallResponse? = nil

    let service: Service
    let command: Command
    let arguments: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            if let response = self.response {
                Label("Successful response received at \(DateFormatter.localizedString(from: response.date, dateStyle: .short, timeStyle: .medium))", systemImage: "clock")
                    .font(.title3)
                List {
                    if response.rows.isEmpty {
                        Text("There is no response body to show you.")
                    } else {
                        ForEach(response.rows.indices, id: \.self) { index in
                            Text(try! AttributedString(markdown: response.rows[index]))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(index % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
                        }
                    }
                }
            } else {
                Label("Waiting for response...", systemImage: "clock")
                    .font(.title3)
            }
        }
        .alert(isPresented: $showingError) {
            Alert(title: Text("Error"), message: Text("\(self.errorMessage) (Details: \(self.errorDetails))"), dismissButton: .default(Text("OK")) {
                self.dismiss()
            })
        }
        .padding()
        .navigationTitle("\(service.name) — \(command.name) — Response")
        .task {
            let proxy = ProxyOfService(zmqContext: zmqContext.get()!, endpoint: self.service.endpoint)
            do {
                let rows = try proxy.invoke(command: self.command.name, arguments: self.arguments)
                let date = Date()
                self.response = ServiceCallResponse(date: date, rows: rows)
            } catch let e as SCError {
                errorMessage = "Couldn't complete the service command."
                errorDetails = e.localizedDescription
                showingError = true
            } catch let e as SCBackendError {
                errorMessage = "Couldn't complete the service command."
                errorDetails = e.localizedDescription
                showingError = true
            } catch let e {
                errorMessage = "Couldn't complete the service command."
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

//struct ServiceCallResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServiceCallResultView()
//            .environmentObject(ZMQContext())
//    }
//}
