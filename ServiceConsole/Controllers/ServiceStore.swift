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
