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
        
        let expectation1 = expectation(description: "Get all my feeds")
        URLRequest(forTestWithMethod: "GET")
            .sendForTesting(expectation: expectation1)  {
                data, expectation in
                print(String(data: data, encoding: String.Encoding.utf8)!)
                expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
    
    func testGetUserBleets() {
        
        let expectation1 = expectation(description: "Get all the user feeds")
        URLRequest(forTestWithMethod: "GET", user: "Chia")
            .sendForTesting(expectation: expectation1) {
                data, expectation in
                print(String(data: data, encoding: String.Encoding.utf8)!)
                expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
    
    func testFollowAuthor() {
        
        let expectation1 = expectation(description: "Follow the author")
        URLRequest(forTestWithMethod: "PUT", user: "rfdickerson")
            .sendForTesting(expectation: expectation1) {
                data, expectation in
                    print(String(data: data, encoding: String.Encoding.utf8)!)
                    expectation1.fulfill()
        }
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
    
    func testBleet() {
        
        let expectation1 = expectation(description: "Post a Bleet")
        let message = "I just bleeted!"
        URLRequest(forTestWithMethod: "POST", message: message)
            .sendForTesting(expectation: expectation1) {
                data, expectation in
                print(String(data: data, encoding: String.Encoding.utf8)!)
                expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: { _ in  })
    }

    // Cannot store and retrieve a Bleet yet; maybe someday:
    // too many hardwired user IDs in BitterController
    //    func testBleetAndFollow() {
    //
    //        let expectation1 = expectation(description: "Post a Bleet and receive it")
    //        let message = "I just bweeted!"
    //        URLRequest(forTestWithMethod: "POST", message: message)
    //            .sendForTesting(expectation: expectation1) {
    //                data, expectation in
    //                URLRequest(forTestWithMethod: "GET", user: "Jack")
    //                    .sendForTesting(expectation: expectation1) {
    //                        data, expectation in
    //                        let obj: Any
    //                        do {  obj = try JSONSerialization.jsonObject(with: data)  }
    //                        catch { XCTFail("JSON error \(error.localizedDescription)"); return  }
    //                        guard let arr = obj as? [Any]  else { XCTFail("not array");  return  }
    //                        let messages = Set( arr.flatMap { ($0 as? [String: Any])?["message"] as? String} )
    //                        guard messages.count == 2  else { XCTFail("bad count \(messages)"); return }
    //                        guard messages.contains(message)  &&  messages.contains("Having a blast at Try! Swift")  else {
    //                            XCTFail("bad messages: \(messages)")
    //                            return
    //                        }
    //                        expectation.fulfill()
    //                }
    //        }
    //        waitForExpectations(timeout: 5, handler: { _ in  })
    //    }
}


private extension URLRequest {
    init(forTestWithMethod method: String, user: String = "", message: String? = nil) {
        self.init(url: URL(string: "http://127.0.0.1:8080/" + user)!)
        addValue("application/json", forHTTPHeaderField: "Content-Type")
        switch method {
        case "POST":
            addValue("application/json", forHTTPHeaderField: "Accept")
            httpBody = try! JSONSerialization.data(withJSONObject: ["message": message!])

        default:
            assert(message == nil)
            break
        }
        httpMethod = method
        cachePolicy = .reloadIgnoringCacheData
    }

    func sendForTesting(expectation: XCTestExpectation,  fn: @escaping (Data, XCTestExpectation) -> Void ) {
        let dataTask = URLSession(configuration: .default).dataTask(with: self) {
            data, response, error in
            XCTAssertNil(error)
            XCTAssertNotNil(data)
            switch (response as? HTTPURLResponse)?.statusCode {
            case nil: XCTFail("bad response")
            case 200?: fn(data!, expectation)
            case let sc?: XCTFail("bad status \(sc)")
            }
        }
        dataTask.resume()
    }
}
