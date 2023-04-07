//
//  ResultView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import SwiftUI
import SwiftyZeroMQ

struct ResultView: View {
    @Binding var result: ServiceCallResult<[String]>

    var body: some View {
        VStack {
            switch result {
            case .ready:
                Text("Please invoke a remote function.")
                    .font(.headline)
                    .padding(.bottom)

            case .ok(let date, let response):
                Text("Response received at \(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium))")
                if response.isEmpty {
                    Text("There was no message.")
                } else {
                    List {
                        ForEach(response.indices, id: \.self) { index in
                            Text(try! AttributedString(markdown: response[index]))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(index % 2 == 0 ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
                        }
                    }
                }

            case .error(let date, let error):
                Text("Error received at \(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .medium))")
                    .font(.headline)
                    .padding(.bottom)
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Result")
    }
}

//struct ResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultView()
//    }
//}
