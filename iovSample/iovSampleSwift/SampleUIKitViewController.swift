//
//  SampleUIKitViewController.swift
//  iovSampleSwift
//
//  Copyright © 2017 iovation Inc. All rights reserved.
//

import UIKit
import FraudForce

class SampleUIKitViewController: UIViewController {
    @IBOutlet weak var blackboxTextView: UITextView!
    @IBOutlet weak var urlField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        urlField.text = UserDefaults.standard.string(forKey: "blackboxURL")
        generateBlackbox()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blackboxTextView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func generateBlackbox() {
        let blackbox = FraudForce.blackbox()
        blackboxTextView.text = blackbox
        if blackboxTextView.contentOffset.y != 0.0 {
            blackboxTextView.contentOffset = CGPoint(x: 0.0, y: 0.0)
        }
    }
    
    func displayAlert(message: String, title: String = "Cannot Submit") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func submitBlackbox() {
        if let urlString = urlField.text, !urlString.isEmpty {
            // Ensure the URL meets expectations.
            guard let postUrl = URL(string: urlString),
                let urlScheme = postUrl.scheme, urlScheme.hasPrefix("http"),
                let urlResourceSpec = (postUrl as NSURL).resourceSpecifier, urlResourceSpec.contains("//") else {
                    self.displayAlert(message: "Invalid URL format. Example: https://yourdomain.com/resource")
                    return
            }
            urlField.resignFirstResponder()
            // Generate the blackbox string (if one is not already populating the text-view).
            if blackboxTextView.text.isEmpty {
                self.generateBlackbox()
            }
            
            // Create the blackbox to send in your request.
            guard let blackbox = blackboxTextView.text, let messageBody = "bb=\(blackbox)".data(using: .utf8) else {
                self.displayAlert(message: "Failed to convert blackbox string to data")
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
                    self.displayAlert(message: "\(statusCode): \(statusMessage)", title: "Request Response")
                }
            })
            submitBoxTask.resume()
        } else {
            self.displayAlert(message: "Please enter a URL!")
        }
    }
}

extension SampleUIKitViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === urlField {
            UserDefaults.standard.set(urlField.text, forKey: "blackboxURL")
            UserDefaults.standard.synchronize()
        }
    }
}
