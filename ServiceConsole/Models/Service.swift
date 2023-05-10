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
