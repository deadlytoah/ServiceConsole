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
