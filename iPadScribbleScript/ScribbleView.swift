//
//  ScribbleView.swift
//  iPadScribbleScript
//
//  Created by Kelvin J on 1/11/25.
//

import SwiftUI
import PencilKit
import UIKit

struct CanvasView: UIViewRepresentable {
    // Binding to the PKCanvasView instance
    @Binding var canvasView: PKCanvasView
    @Binding var pencilOnly: Bool

    // Creates and configures the PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView {
        // Allows drawing with any input (finger or Apple Pencil)
        
        canvasView.drawingPolicy = pencilOnly ? .pencilOnly : .default
        return canvasView
    }

    // Updates the PKCanvasView when SwiftUI state changes
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // No updates needed for this simple implementation
        uiView.drawingPolicy = pencilOnly ? .pencilOnly : .anyInput
    }
}

struct ScribbleView: View {
    @StateObject private var ec2ViewModel = EC2ViewModel()
//    @State private var apiResponse: String = ""
    
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var pencilOnly: Bool = false
    
    @State private var image: Image?
    @State private var base64String: String?
    
    
    

    var body: some View {
        VStack {
            // Embeds the CanvasView within the SwiftUI view hierarchy
            CanvasView(canvasView: $canvasView, pencilOnly: $pencilOnly)
                .onAppear {
                    // Configure and display the tool picker when the view appears
                    if let window = UIApplication.shared.windows.first {
                        // Make the tool picker visible and associate it with the canvas view
                        toolPicker.setVisible(true, forFirstResponder: canvasView)
                        // Add the canvas view as an observer to the tool picker
                        toolPicker.addObserver(canvasView)
                        // Make the canvas view the first responder to receive input
                        canvasView.becomeFirstResponder()
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
            
            HStack {
                // Group the buttons on the left side
                HStack {
                    Button(action: clearCanvas) {
                        Text("Clear")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    Button(action: {
                        // Action for compile code
//                        let imgRect = CGRect(x: 0, y: 0, width: 400, height: 80)
                        let imgRect = canvasView.bounds
                        let uiImage: UIImage = canvasView.drawing.image(from: imgRect, scale: 1.0)
                        self.image = Image(uiImage: uiImage)
                        
                        // convert to base 64
                        let b64 = uiImage.base64
                        let rebornImg = b64?.imageFromBase64
                                                
                        base64String = b64!
                        
                        if let window = UIApplication.shared.windows.first {
                            toolPicker.setVisible(true, forFirstResponder: canvasView)
                            toolPicker.addObserver(canvasView)
                            canvasView.becomeFirstResponder()
                        }
                    }) {
                        Text("Save Image (convert to base64)")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    Button(action: {
                        if (base64String != nil) {
                            ec2ViewModel.imageProcess(base64String: base64String!)
                        }
                    }) {
                        Text("Execute Vision Model")
                            .padding()
                            .background(base64String == nil ? Color.blue.opacity(0.5) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }.disabled(base64String == nil)


                    Button(action: {
                        
                    }) {
                        Text("Compile code")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }

                Spacer()
                HStack {
                    Text("Draw with Pencil Only")
                    Toggle("", isOn: $pencilOnly)
                        .labelsHidden()
                }
            }
            .padding()
            
            if (self.image != nil) {
                Text("displayed now:")
                self.image
            }
            
        }
    }
    func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
}


