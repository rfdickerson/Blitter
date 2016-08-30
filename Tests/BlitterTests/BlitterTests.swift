/**
 Copyright IBM Corporation 2016
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import Kitura
import XCTest

@testable import Blitter

class BlitterTests: XCTestCase {

//    private var router: Router!
    
    private var defaultSession: URLSession!
    
    private var dataTask: URLSessionDataTask?
    
    private var uploadTask: URLSessionUploadTask?
    
    static var allTests : [(String, (BlitterTests) -> () throws -> Void)] {
        return [
            ("testFollowAuthor", testFollowAuthor),
            ("testGetAllMyFeeds", testGetAllMyFeeds),
            ("testGetUserTweets", testGetUserTweets),
            ("testTweet", testTweet)
        ]
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        defaultSession =  URLSession(configuration: .default)
        //URLSession(configuration: URLSession.shared.configuration)
    }
    
    func testGetAllMyFeeds() {
        
        let expectation1 = expectation(description: "Get all my feeds")
        
        if dataTask != nil {
            dataTask?.cancel()
        }

        var url: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/")!)
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.httpMethod = "GET"
        url.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            print(data)
            print(response)
            print(error)
             if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(String(data: data!, encoding: String.Encoding.utf8)!)
                    expectation1.fulfill()
                }
            }
        }
        dataTask?.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })

    }
    
    func testGetUserTweets() {
        
        let expectation1 = expectation(description: "Get all the user feeds")
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let user: String = "Chia"
        var url: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/\(user)")!)
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.httpMethod = "GET"
        url.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(String(data: data!, encoding: String.Encoding.utf8)!)
                    expectation1.fulfill()
                }
            }
        }
        dataTask?.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
    
    func testFollowAuthor() {
        
        let expectation1 = expectation(description: "Follow the author")
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let user: String = "rfdickerson"
        var url: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/\(user)")!)
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.httpMethod = "PUT"
        url.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        uploadTask = defaultSession.uploadTask(with: url, from: url.httpBody) {
            data, response, error in
            XCTAssertNil(error)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(String(data: data!, encoding: String.Encoding.utf8)!)
                    expectation1.fulfill()
                }
            }
        }
        dataTask?.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
    
    func testTweet() {
        
        let expectation1 = expectation(description: "Post a tweet")
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        var url: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/")!)
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.httpMethod = "POST"
        url.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        uploadTask = defaultSession.uploadTask(with: url, from: url.httpBody) {
            data, response, error in
            XCTAssertNil(error)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(String(data: data!, encoding: String.Encoding.utf8)!)
                    expectation1.fulfill()
                }
            }
        }
        dataTask?.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
}
