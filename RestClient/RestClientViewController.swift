//
//  RestClientViewController.swift
//  iOSExamples
//
//  Created by Ji Wang on 2017-06-18.
//  Copyright © 2017 Ji Wang. All rights reserved.
//

import UIKit

class RestClientViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate{
    @IBOutlet weak var reqponseLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var queryTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        urlTextField.delegate = self
        queryTextField.delegate = self
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
        let queryString = queryTextField.text!
        
        let url = URL(string: urlString + "/" + queryString)
        let restClient = RestClient()
        
        restClient.request(
            method: "PUT",
            url: url!,
            completion: {(result:Data?) in
                do {
                    let json = try JSONSerialization.jsonObject(with: result!, options:.allowFragments) as! [String : Any]
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
            },
            errorHandler: {(errorMessage:String) in
                print("error=\(String(describing: errorMessage))")
            }
        )
    }
}
