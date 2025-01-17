//
//  SearchTextField.swift
//  NooroTest
//
//  Created by jonathan thornburg on 1/15/25.
//

import SwiftUI

struct SearchTextFieldStyle: TextFieldStyle {
    let onSearchTapped: () -> Void
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.leading, 16)
            .padding(.trailing, 40)
            .frame(height: 46)
            .font(.custom("Poppins-Regular", size: 15))
            .background {
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 242/255, green: 242/255, blue: 242/255))
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0)
                    Button(action: onSearchTapped) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 16)
                }
            }
    }
}

struct SearchTextField: View {
    let placeholder: String = "Search Location"
    let onSearch: () -> Void
    @Binding var text: String
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(SearchTextFieldStyle(onSearchTapped: onSearch))
            .padding(.horizontal, 16)
            .padding(.top, 24)
    }
}

