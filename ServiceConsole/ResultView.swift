//
//  ResultView.swift
//  ServiceConsole
//
//  Created by Hee Suk Shin on 2023/03/30.
//

import SwiftUI

struct ResultView: View {
    let request: Request
    let result: [String]? = nil
    let error: String? = nil

    var body: some View {
        VStack {
            if let result = result {
                Text("Result:")
                    .font(.headline)
                    .padding(.bottom)

                List(result, id: \.self) {
                    Text($0)
                }
            } else if let error = error {
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
