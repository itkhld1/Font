//
//  ContentView.swift
//  Font
//
//  Created by itkhld on 2024-10-30.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var sampleText = "Preview your font here"
    @State private var fontSize: CGFloat = 24
    @State private var fontColor: Color = .black
    @State private var showingCopyAlert = false
    
    let fontOptions: [(name: String, fontName: String)] = [
        ("Body", ""),
        ("Badge", "Badge"),
        ("Bouquets", "Bouquets"),
        ("Ariana Violeta", "ArianaVioleta"),
        ("Chilispepper", "chilispepper"),
        ("FREEDOM", "FREEDOM"),
        ("Gotten", "Gotten"),
        ("Jasmine", "Jasmine"),
        ("Morgan Chalk", "MorganChalk"),
        ("MTF Saxy", "MTFSaxy"),
        ("MTFBirthdayBashDoodles", "MTFBirthdayBashDoodles"),
        ("Short Baby", "ShortBaby"),
        ("Beautiful Beach", "BeautifulBeach"),
        ("rhaven", "rhaven"),
        ("Sister", "Sister"),
        ("Cake", "Cake"),
        ("Konimasa", "Konimasa"),
        ("Cocoa Trial Version", "CocoaTrialVersion"),
        ("Christmas Jewelry", "ChristmasJewelryTTFDemo")
    ]
    
    @State private var selectedFontName: String = ""
    
    private var currentFont: Font {
        selectedFontName.isEmpty ? .system(size: fontSize) : .custom(selectedFontName, size: fontSize)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Font Settings")) {
                    Picker("Select Font", selection: $selectedFontName) {
                        ForEach(fontOptions, id: \.fontName) { option in
                            Text(option.name)
                                .tag(option.fontName)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    ColorPicker("Select Font Color", selection: $fontColor)
                }
                
                Section(header: Text("Text Customization")) {
                    VStack(alignment: .leading) {
                        Text("Font Size: \(Int(fontSize))")
                        Slider(value: $fontSize, in: 10...100, step: 1) {
                        } minimumValueLabel: {
                            Image(systemName: "minus")
                        } maximumValueLabel: {
                            Image(systemName: "plus")
                        }
                        .padding()
                    }
                }
                
                Section(header: Text("Preview")) {
                    TextEditor(text: $sampleText)
                        .font(currentFont)
                        .foregroundColor(fontColor)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(minHeight: 200, maxHeight: 300)
                        .cornerRadius(10)
                    
                    Button(action: {
                        copyTextAsImage()
                    }, label: {
                        Text("Copy Font as Image")
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                    .alert(isPresented: $showingCopyAlert) {
                        Alert(title: Text("Copied!"),
                              message: Text("The styled text has been copied as an image."),
                              dismissButton: .default(Text("OK")))
                    }
                }
            }
            .navigationTitle("Font Customizer")
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    func copyTextAsImage() {
        // Determine the correct UIFont for measurement
        let uiFont: UIFont
        if selectedFontName.isEmpty {
            uiFont = .systemFont(ofSize: fontSize)
        } else {
            uiFont = UIFont(name: selectedFontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        }
        
        // Measure text size with NSString for accurate sizing
        let nsString = sampleText as NSString
        let textRect = nsString.boundingRect(
            with: CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: uiFont],
            context: nil
        )
        
        // Define the target size, adding padding for aesthetics
        let targetSize = CGSize(width: 300, height: textRect.height + 20)
        
        // Create a hosting controller to capture SwiftUI view as an image
        let hostingController = UIHostingController(rootView:
            Text(sampleText)
                .font(currentFont)
                .foregroundColor(fontColor)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.clear)
        )
        
        // Set up hosting controller view bounds and force layout
        let rootView = hostingController.view
        rootView?.bounds = CGRect(origin: .zero, size: targetSize)
        rootView?.backgroundColor = .clear
        rootView?.layoutIfNeeded()
        
        // Renderer setup for transparency
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        // Capture the rendered image
        let image = renderer.image { _ in
            rootView?.drawHierarchy(in: rootView!.bounds, afterScreenUpdates: true)
        }
        
        // Copy the image to clipboard and show alert
        UIPasteboard.general.image = image
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Delay the alert presentation to ensure smooth UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showingCopyAlert = true
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
