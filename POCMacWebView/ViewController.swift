//
//  ViewController.swift
//  PocMC
//
//  Created by Fellipe on 9/18/20.
//

import UIKit
import WebKit
import SafariServices

var counter = 0

class ViewController: UIViewController, WKUIDelegate, SFSafariViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var webView: WKWebView!
    var userContentController: WKUserContentController!

    var counter: Int = 0
    
    
    @IBAction func openURL(_ sender: Any) {
            // check if website exists
            guard let url = URL(string: "https://poc-webview-web.vercel.app/") else {
                return
            }
            
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
            
            safariVC.delegate = self
        }
    
    @IBAction func openCamera(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            controller.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string:"https://poc-webview-web.vercel.app/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()

        userContentController = WKUserContentController()
        userContentController.add(self, name: "showToast")
        webConfiguration.userContentController = userContentController

        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self

        view = webView
    }
    
    func showToast(message : String, seconds: Double = 1.0) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.red
        alert.view.alpha = 1
        alert.view.layer.cornerRadius = 15
        
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    func loadJavascript() {
        let scriptSource = "document.callme();"
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(script)
    }
    
    func injectJavascript(script: String)  {
//        let script = "document.getElementById('value').innerText = \"\(message)\""

        webView.evaluateJavaScript(script) { (result, error) in
            if let result = result {
                print("Label is updated with message: \(result)")
            } else if let error = error {
                print("An error occurred: \(error)")
            }
        }
    }
}

extension ViewController: WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "showToast", let messageBody = message.body as? String {
        print("[LOG] ->" + messageBody)
        showToast(message: messageBody)
//        openCamera("")
      }
  }
}

