//
//  SymbolPicker.swift
//  Intent
//
//  Created by Santiago Garcia Santos on 26/12/2022.
//

import SwiftUI

struct SymbolPicker: View {
    
    private static let symbols: [String] = {
        guard let path = Bundle.main.path(forResource: "sfsymbols", ofType: "txt"),
              let content = try? String(contentsOfFile: path)
        else {
            return []
        }
        return content.replacingOccurrences(of: ".fill\n", with: "\n")
            .split(separator: "\n")
            .map { String($0)}
    }()
    
    // MARK: - Properties

    @Binding public var symbol: String
    @State private var searchText = ""
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - Public Init

    public init(symbol: Binding<String>) {
        _symbol = symbol
    }
    
    var body: some View {NavigationView {
        
        symbolGrid
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    private var symbolGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 64, maximum: 64))]) {
                ForEach(Self.symbols.filter { searchText.isEmpty ? true : $0.replacingOccurrences(of: ".", with: " ").localizedCaseInsensitiveContains(searchText) }, id: \.self) { thisSymbol in
                    Button(action: {
                        symbol = thisSymbol
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        if thisSymbol == symbol {
                            Image(systemName: thisSymbol)
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).foregroundColor(.accentColor))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: thisSymbol)
                                .font(.system(size: 24))
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(Color(uiColor: UIColor.systemBackground))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct SymbolPicker_Previews: PreviewProvider {
    static var previews: some View {
        SymbolPicker(symbol: .constant(""))
    }
}
