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
import Dispatch
import HeliumLogger
import SwiftyJSON

@testable import Blitter

class BlitterTests: XCTestCase {
    
    
    private let queue = DispatchQueue(label: "Kitura runloop", qos: .userInitiated, attributes: .concurrent)
    
    private let blitterController = BlitterController()
    
    static var allTests : [(String, (BlitterTests) -> () throws -> Void)] {
        return [
            ("testFollowAuthor", testFollowAuthor),
            ("testGetAllMyFeeds", testGetAllMyFeeds),
            ("testGetUserBleets", testGetUserBleets),
            ("testBleet", testBleet)
        ]
    }
    
    override func setUp() {
        super.setUp()
        
        HeliumLogger.use()
        
        Kitura.addHTTPServer(onPort: 8080, with: blitterController.router)
        
        queue.async {
            Kitura.run()
        }
        //URLSession(configuration: URLSession.shared.configuration)
    }
    
    func testGetAllMyFeeds() {
        
        let defaultSession = URLSession(configuration: .default)
        
        // let dataTask: URLSessionDataTask?
        
        let expectation1 = expectation(description: "Get all my feeds")
        
//        if dataTask != nil {
//            dataTask?.cancel()
//        }

        var url: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/")!)
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.httpMethod = "GET"
        url.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        let dataTask = defaultSession.dataTask(with: url) {
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
        
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })

    }
    
    func testGetUserBleets() {
        
        let expectation1 = expectation(description: "Get all the user feeds")
        
        let defaultSession = URLSession(configuration: .default)
        

        let user: String = "Chia"
        var url: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/\(user)")!)
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.httpMethod = "GET"
        url.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        let dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(String(data: data!, encoding: String.Encoding.utf8)!)
                    expectation1.fulfill()
                }
            }
        }
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
    
    func testFollowAuthor() {
        
        let expectation1 = expectation(description: "Follow the author")
        
        let defaultSession = URLSession(configuration: .default)
        
        let user: String = "rfdickerson"
        var url: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/\(user)")!)
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.httpMethod = "PUT"
        url.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        let dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(String(data: data!, encoding: String.Encoding.utf8)!)
                    expectation1.fulfill()
                }
            }
        }
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
    
    func testBleet() {
        
        let expectation1 = expectation(description: "Post a tweet")
        
        let defaultSession = URLSession(configuration: .default)
        
        var url: URLRequest = URLRequest(url: URL(string: "http://127.0.0.1:8080/")!)
        url.addValue("application/json", forHTTPHeaderField: "Content-Type")
        url.addValue("application/json", forHTTPHeaderField: "Accept")
        url.httpMethod = "POST"
        url.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        let json = "{\"message\": \"I just tweeted!\"}"
        
        url.httpBody = json.data(using: String.Encoding.utf8)
        let dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print(String(data: data!, encoding: String.Encoding.utf8)!)
                    expectation1.fulfill()
                }
            }
        }
        
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
}
