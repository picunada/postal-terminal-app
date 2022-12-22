//
//  InputFields.swift
//  locker-test
//
//  Created by Danil Bezuglov on 11/29/22.
//

import SwiftUI

extension Binding {
    func optionalBinding<T>() -> Binding<T>? where T? == Value {
        if let wrappedValue = wrappedValue {
            return Binding<T>(
                get: { wrappedValue },
                set: { self.wrappedValue = $0 }
            )
        } else {
            return nil
        }
    }
}

struct TextInputField: View {
    @Environment(\.isEnabled) var isEnabled
    
    var title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color(.secondarySystemBackground)
            
            if text.isEmpty {
                Text("\(title)")
                    .padding(.leading, 16)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                TextField("", text: $text)
                    .autocapitalization(.none)
                    .padding()
                    .focused($isFocused)
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
            .padding(.trailing)
            
        }
        .onTapGesture {
                        isFocused = true
                    }
        .animation(.default, value: text.isEmpty)
    }
}

struct SecureInputField: View {
    var title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    @State var isSecured: Bool = true
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color(.secondarySystemBackground)
            
            if text.isEmpty {
                Text("\(title)")
                    .padding(.leading, 16)
                    .foregroundColor(.secondary)
            }
            
            
            if(isSecured) {
                HStack {
                    SecureField("", text: $text)
                        .font(.custom("Password", fixedSize: 17))
                        .autocapitalization(.none)
                        .padding()
                        .focused($isFocused)
                    Button {
                        isSecured.toggle()
                    } label: {
                        Image(systemName: "eye")
                            .foregroundColor(Color(.placeholderText))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(.trailing)
            } else {
                HStack {
                    TextField("", text: $text)
                        .font(.custom("Password", fixedSize: 17))
                        .autocapitalization(.none)
                        .padding()
                        .focused($isFocused)
                    Button {
                        isSecured.toggle()
                    } label: {
                        Image(systemName: "eye.slash")
                            .foregroundColor(Color(.placeholderText))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(.trailing)
            }
        }
        .onTapGesture {
                        isFocused = true
                    }
        .animation(.default, value: text.isEmpty)
    }
}
