//
//  CodeBlockView.swift
//  iPadScribbleScript
//
//  Created by Kelvin J on 1/11/25.
//

import SwiftUI

struct CodeBlockView: View {
    var code: String
    var body: some View {
        VStack {
            // Background that stretches the whole screen
            ScrollView(.horizontal) {
                Text(attributedString(for: code)) // Display the formatted code
                    .font(.system(.body, design: .monospaced)) // Use monospaced font
                    .padding()
                    .background(Color.black) // Dark background for the code block
                    .cornerRadius(8) // Rounded corners
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 0) // Add a gray border
                    )
                    .shadow(radius: 2) // Slight shadow for depth
                    .multilineTextAlignment(.leading) // Left-align the code
                    .foregroundColor(.white) // Default text color
                    .frame(maxWidth: 600) // Set a max width for the code block content
            }
        }
        .background(Color.black) // This will stretch the entire width of the screen
        .cornerRadius(8) // Rounded corners for the background
        .padding(.horizontal)
        
    }
    
    func attributedString(for code: String) -> AttributedString {
        var attributedString = AttributedString(code)
        // Define Swift keywords and regex pattern for strings
        let keywords = ["const", "int", "#include", "if", "else", "struct", "void", "return", "for", "string"]
        let stringPattern = "\\\\\".*?\\\\\"" // Regex pattern to match strings
        // Highlight keywords
        for keyword in keywords {
            let ranges = code.ranges(of: keyword)
            for range in ranges {
                if let attributedRange = Range(NSRange(range, in: code), in: attributedString) {
                    attributedString[attributedRange].foregroundColor = .blue // Highlight keywords in blue
                }
            }
        }
        // Highlight strings (text within quotation marks)
        if let regex = try? NSRegularExpression(pattern: stringPattern) {
            let matches = regex.matches(in: code, range: NSRange(code.startIndex..., in: code))
            for match in matches {
                if let stringRange = Range(match.range, in: code),
                   let attributedRange = Range(NSRange(stringRange, in: code), in: attributedString) {
                    attributedString[attributedRange].foregroundColor = .green // Highlight strings in green
                }
            }
        }
        return attributedString
    }
}


extension String {
    /// Helper to find all ranges of a substring within a string
    func ranges(of substring: String) -> [Range<String.Index>] {
        var result: [Range<String.Index>] = []
        var startIndex = self.startIndex
        while startIndex < self.endIndex,
              let range = self.range(of: substring, range: startIndex..<self.endIndex) {
            result.append(range)
            startIndex = range.upperBound
        }
        return result
    }
}
