//
//  ServiceConsoleApp.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/29.
//

import SwiftUI
import SwiftyZeroMQ

class ZMQContext: ObservableObject {
    @Published var context: SwiftyZeroMQ.Context?

    init() {
        do {
            self.context = try SwiftyZeroMQ.Context()
        } catch {
            self.context = nil
        }
    }

    func get() -> SwiftyZeroMQ.Context? {
        context
    }
}

@main
struct ServiceConsoleApp: App {
    let zmqContext = ZMQContext()
    let serviceStore = ServiceStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(zmqContext)
                .environmentObject(serviceStore)
        }
    }
}
