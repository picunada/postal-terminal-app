//
//  InputFields.swift
//  locker-test
//
//  Created by Danil Bezuglov on 11/29/22.
//

import SwiftUI

struct TextInputField: View {
    var title: String
    @Binding var text: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                TextField("", text: $text)
                    .autocapitalization(.none)
                Button {
                    text = ""
                } label: {
                    if (!text.isEmpty)
                    {
                        Image(systemName: "multiply")
                            .foregroundColor(.accentColor)
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .disabled(text.isEmpty)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            Text(title)
                .foregroundColor(text.isEmpty ? Color(.placeholderText) : .accentColor)
                .background(.clear)
                .offset(y: text.isEmpty ? 0 : -22)
                .scaleEffect(text.isEmpty ? 1 : 0.8, anchor: .leading)
                .padding(.leading, 15)
        }
        .animation(.default, value: text.isEmpty)
    }
}

struct SecureInputField: View {
    var title: String
    @Binding var text: String
    
    @State var isSecured: Bool = true
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if(isSecured) {
                HStack {
                    SecureField("", text: $text)
                        .autocapitalization(.none)
                    Button {
                        isSecured.toggle()
                    } label: {
                        Image(systemName: "eye")
                            .foregroundColor(Color(.placeholderText))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            } else {
                HStack {
                    TextField("", text: $text)
                        .autocapitalization(.none)
                    Button {
                        isSecured.toggle()
                    } label: {
                        Image(systemName: "eye.slash")
                            .foregroundColor(Color(.placeholderText))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }
            Text(title)
                .foregroundColor(text.isEmpty ? Color(.placeholderText) : .accentColor)
                .background(.clear)
                .offset(y: text.isEmpty ? 0 : -22)
                .scaleEffect(text.isEmpty ? 1 : 0.8, anchor: .leading)
                .padding(.leading, 15)
        }
        .animation(.default, value: text.isEmpty)
    }
}
