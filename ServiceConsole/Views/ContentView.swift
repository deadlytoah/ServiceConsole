//
//  ContentView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var zmqContext: ZMQContext
    @EnvironmentObject var serviceStore: ServiceStore

    @State private var listOfServices: [Service] = []

    @State var showingError: Bool = false
    @State var errorMessage: String = ""
    @State var errorDetails: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(serviceStore.services) { service in
                    NavigationLink(destination: ServiceDetailView(service: service)) {
                        VStack(alignment: .leading) {
                            Text(service.name)
                                .font(.headline)
                            Text(service.description)
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: removeServices)
            }
            .alert(isPresented: self.$showingError) {
                Alert(title: Text("Error"), message: Text("\(self.errorMessage) (Details: \(self.errorDetails))"), dismissButton: .default(Text("OK")))
            }
            .padding()
            .navigationTitle("List of Services")
            .toolbar {
                NavigationLink(destination: AddServiceView()) {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private func removeServices(at offsets: IndexSet) {
        do {
            try self.serviceStore.removeServices(atOffsets: offsets)
        } catch let error as SCError {
            self.showingError = true
            self.errorMessage = "Couldn't remove the service."
            self.errorDetails = error.localizedDescription
        } catch let error {
            self.showingError = true
            self.errorMessage = "Couldn't remove the service."
            self.errorDetails = error.localizedDescription
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ZMQContext())
            .environmentObject(ServiceStore())
    }
}
