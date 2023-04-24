//
//  Service.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/04/11.
//

import Foundation

struct Service: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var endpoint: String

    init(name: String, description: String, endpoint: String) {
        self.name = name
        self.description = description
        self.endpoint = endpoint
    }

    // Add this initializer to conform to Decodable protocol
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        endpoint = try container.decode(String.self, forKey: .endpoint)
    }
}
