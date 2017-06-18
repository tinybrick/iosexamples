//
//  WebBrowserViewController.swift
//  iOSExamples
//
//  Created by Ji Wang on 2017-06-17.
//  Copyright © 2017 Ji Wang. All rights reserved.
//
// Reference: http://swiftdeveloperblog.com/code-examples/create-uiwebview-programmatically-and-load-webpage-using-nsurl/
//

import UIKit

class WebBrowserViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate  {
    @IBOutlet weak var urlTextField: UITextField!
    
    fileprivate var myWebView:UIWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        urlTextField.delegate = self
        registerURLPorotcol()
        addWebView()
    }
    
    // MARK: Initial methods
    private func addWebView() {
        myWebView = UIWebView(
            frame: CGRect(x: urlTextField.frame.origin.x,
                          y: urlTextField.frame.origin.y + urlTextField.bounds.height,
                          width: urlTextField.frame.origin.x + urlTextField.bounds.width,
                          height: UIScreen.main.bounds.height - (urlTextField.frame.origin.y + urlTextField.bounds.height)))
        
        myWebView!.delegate = self
        self.view.addSubview(myWebView!)
        
        
    }
    
    private func registerURLPorotcol(){
        URLProtocol.registerClass(CustomizedURLProtocol.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let urlString = textField.text!
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        myWebView!.loadRequest(request)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        
    }

}
