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
//  ServiceCallView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/04/17.
//

import SwiftUI

struct ServiceCallView: View {
    let service: Service
    let command: Command

    @State private var argumentFields: [String] = []
    @State private var argumentCount = 0

    var body: some View {
        VStack(alignment: .leading) {
            Label("Arguments", systemImage: "list.bullet")
                .font(.title3)
            List {
                if self.argumentCount == 0 {
                    Text("Please add arguments by pressing + button if needed.")
                        .font(.body)
                        .foregroundColor(.gray)
                } else {
                    ForEach(0..<self.argumentCount, id: \.self) { index in
                        TextField("Argument \(index + 1)", text: self.$argumentFields[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit(invoke)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: {
                    self.argumentCount += 1
                    if self.argumentFields.count < self.argumentCount {
                        self.argumentFields.append("")
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 12))
                }
                Button(action: {
                    if self.argumentFields.count > 0 {
                        self.argumentCount -= 1
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 12))
                }
                NavigationLink(destination: ServiceCallResultView(service: service, command: command, arguments: argumentFields)) {
                    Text("Invoke")
                }
            }
        }
        .navigationTitle("\(service.name) — \(command.name)")
        .padding()
    }

    private func invoke() {
        print("invoke")
    }
}

struct ServiceCallView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceCallView(service: Service(name: "email", description: "sends and receives e-mails", endpoint: "tcp://localhost:5555"), command: Command(name: "send", description: "sends an e-mail"))
    }
}
