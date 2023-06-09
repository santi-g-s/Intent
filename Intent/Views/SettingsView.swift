//
//  SettingsView.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 10/01/2023.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @Environment(\.requestReview) var requestReview
    
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("showOnboardingView") var showOnboardingView: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40){
                    VStack(spacing: 20){
                        Image("IntentIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding(.top, 80)
                    
                        VStack {
                            Text("Intent")
                                .font(Font.system(.largeTitle, design: .rounded, weight: .semibold))
                                .foregroundColor(.indigo)
                            Text(UIApplication.appVersion ?? "0.0.0")
                                .foregroundStyle(.tertiary)
                        }
                        
                    }
                    Text("Created with \(Image(systemName: "heart.fill")) by **Sumone Studios**")
                        .foregroundStyle(.secondary)
                }
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    NavigationLink(
                        destination: ScrollView{
                            Text(attributedText).padding()
                        },
                        label: {
                            Tile(systemImage: "eye.slash", text: "Privacy Policy")
                        }
                    )
                    .buttonStyle(.plain)
                                        
                    Button {
                        requestReview()
                    } label: {
                        Tile(systemImage: "star", text: "Leave a Review")
                    }
                    .buttonStyle(.plain)
                    
                    ComposeMailView {
                        Tile(systemImage: "envelope.open", text: "Contact us")
                    }
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        showOnboardingView = true
                    } label: {
                        Tile(systemImage: "info.circle", text: "Show Intro")
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
            }
        }
        
    }
    
    struct Tile: View {
        var systemImage: String
        var text: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16){
                Image(systemName: systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                Text(text)
                    .bold()
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundStyle(.regularMaterial)
            }
        }
    }
    
    var attributedText: AttributedString {
        var string = NSAttributedString(string: "Not available")
        
        if let rtfPath = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "rtf") {
            do {
                let attributedString: NSAttributedString = try NSAttributedString(url: rtfPath, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                
                let dynamicAttributedString: NSMutableAttributedString = attributedString.mutableCopy() as! NSMutableAttributedString
                
                dynamicAttributedString.addAttribute(.foregroundColor, value: Color.primary, range: NSRange(location: 0, length: dynamicAttributedString.length))
                
                
                string = dynamicAttributedString
            }
            
            catch let error {
                print(error)
            }
        }
        
        return try! AttributedString(string, including: \.swiftUI)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension Bundle {
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return iconFileName
    }
}

struct AppIcon: View {
    var body: some View {
        Bundle.main.iconFileName
            .flatMap { UIImage(named: $0) }
            .map { Image(uiImage: $0) }
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
