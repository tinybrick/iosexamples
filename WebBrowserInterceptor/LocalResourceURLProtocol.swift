//
//  LocalResourceURLProtocol.swift
//  iOSExamples
//
//  Created by Ji Wang on 2017-06-18.
//  Copyright © 2017 Ji Wang. All rights reserved.
//
// Reference: https://stackoverflow.com/questions/28024296/swift-how-to-load-local-images-remote-html

import UIKit

class LocalResourceURLProtocol: URLProtocol, URLSessionDataDelegate, URLSessionTaskDelegate {
    public struct Const {
        static let InterceptorURL = "192.168.10.51:8080"
        static let localResource = "/local/"
        static let HandledKEy = "LocalResourceURLProtocol"
    }
    
    private var dataTask: URLSessionDataTask?
    
    // MARK: NSURLProtocol
    override class func canInit(with request: URLRequest) -> Bool {
        guard let localUrl = request.url?.absoluteString, localUrl.contains(Const.InterceptorURL + Const.localResource) else {
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
    
    func getMiniType(_ fileExtension: String) -> String {
        return "image/" + fileExtension
    }
    
    override func startLoading() {
        let requestUrl = request.url!
        let fileName = requestUrl.absoluteString.components(separatedBy: Const.localResource)[1]
        let parts = fileName.components(separatedBy: ".")
        
        // reply with data from a local file
        if let path = Bundle.main.path(forResource: parts[0], ofType: parts[1]) {
            let data = NSData(contentsOfFile: path)
        
            let response = URLResponse(url: requestUrl, mimeType: getMiniType(_: parts[1]), expectedContentLength: (data! as Data).count, textEncodingName: nil)
        
            if let client = self.client {
                //将数据返回到客户端。设置客户端的缓存存储策略.notAllowed ，即不允许客户端做任何缓存的相关工作
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client.urlProtocol(self, didLoad: data! as Data)
            
                //然后调用URLProtocolDidFinishLoading方法来结束加载。
                client.urlProtocolDidFinishLoading(self)
            }
        }
        else {
            let newRequest = (self.request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
            //NSURLProtocol接口的setProperty()方法可以给URL请求添加自定义属性。
            //（这样把处理过的请求做个标记，下一次就不再处理了，避免无限循环请求）
            URLProtocol.setProperty(true, forKey: Const.HandledKEy, in: newRequest)
            
            //使用缺省的URLSession从网络获取数据
            let defaultConfigObj = URLSessionConfiguration.default
            let defaultSession = Foundation.URLSession(configuration: defaultConfigObj,delegate: self, delegateQueue: nil)
            self.dataTask = defaultSession.dataTask(with: self.request)
            self.dataTask!.resume()
        }
        
    }
    
    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask       = nil
    }
    
    // MARK: NSURLSessionDataDelegate
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        
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
