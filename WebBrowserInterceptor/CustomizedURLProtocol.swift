//
//  CustomizedURLProtocol.swift
//  iOSExamples
//
//  Created by Ji Wang on 2017-06-17.
//  Copyright © 2017 Ji Wang. All rights reserved.
//
// Reference: https://stackoverflow.com/questions/36297813/custom-nsurlprotocol-with-nsurlsession
//

import UIKit

class CustomizedURLProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    public struct Const {
        static let InterceptorURL = "192.168.10.51:8080"
        static let HandledKEy = "CustomizedURLProtocol"
    }
    
    private var dataTask: URLSessionDataTask?
    //private var urlResponse: URLResponse?
    //private var receivedData: NSMutableData?
    
    // MARK: NSURLProtocol
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url?.absoluteString, url.contains(Const.InterceptorURL) else {
            return false
        }
        
        if (URLProtocol.property(forKey: Const.HandledKEy, in: request as URLRequest) != nil) {
            return false
        }
        
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let mutableRequest =  NSMutableURLRequest.init(
            url: self.request.url!,
            cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy,
            timeoutInterval: 240.0)//self.request as! NSMutableURLRequest
        
        //Add Authorization Token
        let valueString = "Bearer "
        mutableRequest.setValue(valueString, forHTTPHeaderField: "Authorization")
        
        print(mutableRequest.allHTTPHeaderFields ?? "")
        URLProtocol.setProperty("true", forKey: Const.HandledKEy, in: mutableRequest)
        let defaultConfigObj = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultConfigObj, delegate: self, delegateQueue: nil)
        self.dataTask = defaultSession.dataTask(with: mutableRequest as URLRequest, completionHandler: {
            [weak self] (data, response, error) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                strongSelf.client?.urlProtocol(strongSelf, didFailWithError: error)
                return
            }
            
            strongSelf.client?.urlProtocol(strongSelf, didReceive: response!, cacheStoragePolicy: .allowed)
            strongSelf.client?.urlProtocol(strongSelf, didLoad: data!)
            strongSelf.client?.urlProtocolDidFinishLoading(strongSelf)
        })
        
        self.dataTask!.resume()
        
    }
    
    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask       = nil
        //self.receivedData   = nil
        //self.urlResponse    = nil
    }
    
    // MARK: NSURLSessionDataDelegate
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        //self.urlResponse = response
        //self.receivedData = NSMutableData()
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data as Data)
        
        //self.receivedData?.append(data as Data)
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse,
                           newRequest request: URLRequest,
                           completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
    
    // MARK: NSURLSessionTaskDelegate
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if error != nil { //&& error.code != NSURLErrorCancelled {
            self.client?.urlProtocol(self, didFailWithError: error!)
        } else {
            //saveCachedResponse()
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
}
