//
//  RestClient.swift
//  iOSExamples
//
//  Created by Ji Wang on 2017-06-18.
//  Copyright © 2017 Ji Wang. All rights reserved.
//

import UIKit

class RestClient: URLProtocol {
    public func request(method: String, url: URL, completion: @escaping (_ result: Data?) -> Void, errorHandler: @escaping (_ result: String) -> Void){
        // MARK: Request data
        var request = URLRequest(url: URL(string: url.absoluteString)!)
        request.httpMethod = method
        
        // MARK: Headers
        //request.setValue("", forHTTPHeaderField: "")
        
        let session = URLSession.shared
        session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            guard let data = data, error == nil else {              // check for fundamental networking error
                errorHandler(String(describing: error))
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {      // check for http errors
                switch httpStatus.statusCode {
                case 200 ... 299:
                    // MARK: Processing return data
                    print(String(data: data, encoding: .utf8)!)
                    completion(data)
                default:
                    print("response = \(String(describing: response))")
                }
            }
        }).resume()
    }
}
