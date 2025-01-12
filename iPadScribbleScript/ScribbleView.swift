import SwiftUI
import PencilKit
import UIKit

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var pencilOnly: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = pencilOnly ? .pencilOnly : .default
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawingPolicy = pencilOnly ? .pencilOnly : .anyInput
    }
}

struct ScribbleView: View {
    @StateObject private var ec2ViewModel = EC2ViewModel()
    
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var pencilOnly: Bool = false
    @State private var selectedLanguage = "C++"
    let languages = ["C++", "Python"]
    
    @State private var image: Image?
    @State private var base64String: String?
    
    @State private var loadProgress = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    CanvasView(canvasView: $canvasView, pencilOnly: $pencilOnly)
                        .frame(width: UIScreen.main.bounds.width - 50, height: 750)
                        .onAppear {
                            if let window = UIApplication.shared.windows.first {
                                toolPicker.setVisible(true, forFirstResponder: canvasView)
                                toolPicker.addObserver(canvasView)
                                canvasView.becomeFirstResponder()
                            }
                        }
                        .background(Color.gray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                    
                    HStack {
                        Button(action: clearCanvas) {
                            Text("Clear")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        Button(action: {
                            let imgRect = canvasView.bounds
                            let uiImage: UIImage = canvasView.drawing.image(from: imgRect, scale: 1.0)
                            self.image = Image(uiImage: uiImage)
                            
                            let b64 = uiImage.base64
                            let rebornImg = b64?.imageFromBase64
                            
                            base64String = b64!
                        }) {
                            Text("Save Image (convert to base64)")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        
                        Button(action: {
                            loadProgress = true
                            DispatchQueue.global(qos: .userInitiated).async {
                                if let base64String = base64String {
                                    ec2ViewModel.imageProcess(base64String: base64String)
                                }
                                DispatchQueue.main.async {
                                    self.image = nil
                                    loadProgress = false
                                }
                            }
                        }) {
                            Text("Execute Vision Model")
                                .padding()
                                .background(base64String == nil ? Color.blue.opacity(0.5) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }.disabled(base64String == nil)
                        Spacer()
                        HStack {
                            Text("Draw with Pencil Only")
                            Toggle("", isOn: $pencilOnly)
                                .labelsHidden()
                        }
                    }
                    .padding()
                    
                    if let image = self.image {
                        Text("displayed now:")
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                    
                    if ec2ViewModel.codeResult != nil {
                        CodeBlockView(code: ec2ViewModel.codeResult!)
                        //                    CodeBlockView(code: "#include <iostream> \nint main() { \n cout << \"Hello World\" << endl;\n return 0\n }\n")
                        
                        
                        HStack {
                            Picker("Select Language", selection: $selectedLanguage) {
                                ForEach(languages, id: \.self) { language in
                                    Text(language)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Button(action: {
                                ec2ViewModel.compile(code: ec2ViewModel.codeResult!, language: "cpp")
                            }) {
                                Text("Compile code")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        }
                    }
                    
                    if let compileResult = ec2ViewModel.compileResult {
                        Text(compileResult)
                    }
                }
            }
            if ec2ViewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                ProgressView("Processing...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
            }
        }
    }

    func clearCanvas() {
        canvasView.drawing = PKDrawing()
    }
}
