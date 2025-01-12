//
//  ContentView.swift
//  iPadScribbleScript
//
//  Created by Kelvin J on 1/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = EC2ViewModel()
    var body: some View {
        ScribbleView()
        
//        Button(action: {
//            Task {
//                await viewModel.callAnthropic()
//            }
//        }) {
//            Text("Call Claude")
//        }
//        CodeBlockView(code: "var str = \"hello world\"")
    }
}

#Preview {
    ContentView()
}
