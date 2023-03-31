//
//  ResultView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import SwiftUI
import SwiftyZeroMQ

let SOCKET_TIMEOUT: TimeInterval = 200.0

struct ResultView: View {
    @Binding var result: ServiceCallResult

    var body: some View {
        VStack {
            switch result {
            case .ready:
                Text("Please invoke a remote function.")
                    .font(.headline)
                    .padding(.bottom)

            case .ok(let response):
                Text("Result:")
                    .font(.headline)
                    .padding(.bottom)
                List(response, id: \.self) {
                    Text($0)
                }

            case .error(let error):
                Text("Error:")
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
