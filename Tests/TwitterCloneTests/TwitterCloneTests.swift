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
import TwitterClone

class TwitterCloneTests: XCTestCase {

//    private var router: Router!
    
    private var defaultSession: URLSession!
    
    private var dataTask: URLSessionDataTask?
    
    static var allTests : [(String, (TwitterCloneTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
            ("testGetAllMyFeeds", testGetAllMyFeeds),
            ("testGetUserTweets", testGetUserTweets)
        ]
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual("Hello, World!", "Hello, World!")
    }
    
    func testGetAllMyFeeds() throws {

        if dataTask != nil {
            dataTask?.cancel()
        }

        let url: URL = URL(string: "http://127.0.0.1:8080")!
        dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            
             if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {

                }
            }
        }
        dataTask?.resume()
    }
    
    func testGetUserTweets() throws {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let user: String = "Chia"
        let url: URL = URL(string: "http://127.0.0.1:8080/\(user)")!
        dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {

                }
            }
        }
        dataTask?.resume()
        
    }
}
