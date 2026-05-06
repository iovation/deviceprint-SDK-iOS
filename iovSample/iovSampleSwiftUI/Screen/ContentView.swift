//
//  ContentView.swift
//  iovSampleSwiftUI
//
// Copyright © 2024 TransUnion Inc. All rights reserved.
//

import SwiftUI
import FraudForce

// Alert Item for Error Dialogues
struct AlertItem:Identifiable {
    let id = UUID()
    let title:String
    let message:String
    let dismissalButton: Alert.Button
}

struct AlertContext
{
    static let invalidURL = AlertItem(title: "Cannot Submit", message: "Invalid URL format. Example: https://yourdomain.com/resource", dismissalButton: .default(Text("OK")))
    static let missingURL = AlertItem(title: "Cannot Submit", message: "Please enter a URL!", dismissalButton: .default(Text("OK")))
    static let conversionError = AlertItem(title: "Cannot Submit", message: "Failed to convert blackbox string to data", dismissalButton: .default(Text("OK")))
}

struct ContentView: View {
    
    @State private var website = ""
    @State private var blackbox = FraudForce.blackbox()
    @State private var alertItem: AlertItem?
    @FocusState private var nameIsFocused: Bool


    var body: some View {
        VStack (alignment: .leading) {
            
            // VStack for Logo + "Sample App"
            VStack(alignment: .trailing) {
                
                Image("ioLogo")
                Text("Sample App")
                    .foregroundStyle(Color(red: 104/255, green: 104/255, blue: 104/255))
            }
            .padding()
            
            // HStack for "SwiftUI Integration" + Refresh Button
            HStack {
                Text("SwiftUI Integration")
                    .foregroundStyle(Color(.black))
                
                Button{
                    // Refresh Blackbox
                    blackbox = FraudForce.blackbox()
                } label:{
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
                .tint(Color(red: 99/255, green: 142/255, blue: 123/255))
            }
        }
        
        // HStack for URL textfield + Submit Button
        HStack{
            TextField("", text: $website,
                        prompt: Text("https://api.example.com/bb").foregroundColor(.gray))
                        .textFieldStyle(.roundedBorder)
                        .padding()
                        .focused($nameIsFocused)

            Button{
                
                nameIsFocused = false
                
                if !website.isEmpty {
                    // Ensure the URL meets expectations.
                    guard let postUrl = URL(string: website),
                          let urlScheme = postUrl.scheme, urlScheme.hasPrefix("http"),
                          let urlResourceSpec = (postUrl as NSURL).resourceSpecifier, urlResourceSpec.contains("//") else {
                                alertItem = AlertContext.invalidURL
                                return
                    }
                    
                    guard let messageBody = "bb=\(website)".data(using: .utf8) else {
                        alertItem = AlertContext.conversionError
                        return
                    }
                    
                    // Build your request object to post the blackbox to your server (example).
                    var request = URLRequest(url: postUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 5.0)
                    request.httpMethod = "POST"
                    request.httpBody = messageBody
                    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.addValue("\(messageBody.count)", forHTTPHeaderField: "Content-Length")

                    // Submit an asynchronous request and set up a completion handler.
                    let submitBoxSession = URLSession(configuration: URLSessionConfiguration.default)
                    let submitBoxTask = submitBoxSession.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                        if let httpResponse = response as? HTTPURLResponse {
                            let statusCode = httpResponse.statusCode
                            let statusMessage = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                            if statusCode < 200 || statusCode >= 300 {
                                print("Request failed; status code: \(statusCode)")
                                print("Response: \(statusMessage)")
                            }
                            alertItem = AlertItem(title: "Request Response", message:  "\(statusCode): \(statusMessage)", dismissalButton: .default(Text("OK")))
                        } else if let err = error {
                            alertItem = AlertItem(title: "Error", message: err.localizedDescription, dismissalButton: .default(Text("OK")))
                        }
                    })
                    submitBoxTask.resume()
                }
                else {
                    alertItem = AlertContext.missingURL
                }
                
                UserDefaults.standard.set(website, forKey: "blackboxURL")
                UserDefaults.standard.synchronize()
            } label:{
                Text("Submit")
                    .foregroundStyle(Color(red: 99/255, green: 142/255, blue: 123/255))
            }
            .padding()
        }
        
        // VStack for label and textbox displaying Blackbox
        VStack (alignment: .leading) {
            Text("Blackbox of encrypted device information:")
                .font(.system(size: 13))
                .foregroundStyle(Color(.gray))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))

            ScrollViewReader { reader in
                ScrollView {
                    Text(blackbox)
                        .foregroundStyle(Color(.white))
                        .background(Color(red: 99/255, green: 142/255, blue: 123/255))
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    
                }
            }
        }
        
        // Display Error Alert if any
        .alert(item:$alertItem) { alertItem in
            Alert(title: Text(alertItem.title),
                  message: Text(alertItem.message),
                  dismissButton: alertItem.dismissalButton)
        }

        Spacer()
    }
}

#Preview {
    ContentView()
}


