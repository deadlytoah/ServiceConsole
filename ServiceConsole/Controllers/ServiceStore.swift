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
//  ServiceStore.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/04/11.
//

import Foundation

class ServiceStore: ObservableObject {
    @Published var services: [Service]

    private static let key = "services"

    init() {
        do {
            self.services = try Self.loadServices()
        } catch {
            self.services = []
        }
    }

    private static func loadServices() throws -> [Service] {
        if let data = UserDefaults.standard.data(forKey: key),
           let savedServices = try? JSONDecoder().decode([Service].self, from: data) {
            return savedServices
        } else {
            throw SCError.store("Unable to load services from UserDefaults")
        }
    }

    private static func saveServices(_ services: [Service]) throws {
        if let encoded = try? JSONEncoder().encode(services) {
            UserDefaults.standard.set(encoded, forKey: key)
        } else {
            throw SCError.store("Unable to save services to UserDefaults")
        }
    }

    func addService(_ service: Service) throws {
        let services = self.services + [service]
        try Self.saveServices(services)
        self.services = services
    }

    func removeServices(atOffsets offsets: IndexSet) throws {
        let services = self
            .services
            .enumerated()
            .filter { !offsets.contains($0.offset) }
            .map { $0.element }
        try Self.saveServices(services)
        self.services = services
    }
}
