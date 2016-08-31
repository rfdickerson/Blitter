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
        let url = URLRequest(forTestWithMethod: "GET")
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

        let url = URLRequest(forTestWithMethod: "GET", user: "Chia")
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
        
        let url = URLRequest(forTestWithMethod: "PUT", user: "rfdickerson")
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
        
        let message = "I just tweeted!"
        let url = URLRequest(forTestWithMethod: "POST", message: message)

        let dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            
            switch (response as? HTTPURLResponse)?.statusCode {
            case 200?:
                print(String(data: data!, encoding: String.Encoding.utf8)!)
                expectation1.fulfill()

            case nil:       XCTFail("response not HTTPURLResponse")
            case let code?: XCTFail("bad status: \(code)")
            }
        }
        
        dataTask.resume()
        waitForExpectations(timeout: 5, handler: { _ in  })
    }
    
    
    func testBleetAndFollow() {
        
        let expectation1 = expectation(description: "Post a tweet and receive it")
        
        let defaultSession = URLSession(configuration: .default)
        let message = "I just tweeted!"
        let url = URLRequest(forTestWithMethod: "POST", message: message)
        let dataTask = defaultSession.dataTask(with: url) {
            data, response, error in
            XCTAssertNil(error)
            
            switch (response as? HTTPURLResponse)?.statusCode {
            case nil:       XCTFail("response not HTTPURLResponse")
            case let code? where code != 200: XCTFail("bad status: \(code)")
                
            default:
                let url: URLRequest = URLRequest(forTestWithMethod: "GET")
                let dataTask = defaultSession.dataTask(with: url) {
                    data, response, error in
                    XCTAssertNil(error)
                    
                    switch (response as? HTTPURLResponse)?.statusCode {
                    case nil:       XCTFail("response not HTTPURLResponse")
                    case let code? where code != 200: XCTFail("bad status: \(code)")
                        
                    default:
                        
                        guard let httpResponse = response as? HTTPURLResponse  else {
                            XCTFail("bad type of response: \(type(of: response))")
                            return
                        }
                        guard httpResponse.statusCode == 200  else {
                            XCTFail("bad statusCode \(httpResponse.statusCode)")
                            return
                        }
                        guard let d = data  else { XCTFail("no data");  return }
                        let obj: Any
                        do {  obj = try JSONSerialization.jsonObject(with: d)  }
                        catch { XCTFail("JSON error \(error.localizedDescription)"); return  }
                        guard let arr = obj as? [Any]  else { XCTFail("not array");  return  }
                        guard arr.count == 1           else { XCTFail("bad count \(arr.count)"); return }
                        guard let bleet = arr.first! as? [String: Any]  else {XCTFail("not a dictionary"); return }
                        guard (bleet["message"] as? String) == message  else { XCTFail("bad bleet: \(bleet)") ; return }
                        expectation1.fulfill()
                    }
                }
                dataTask.resume()
            }
        }
        
        dataTask.resume()
        waitForExpectations(timeout: 10, handler: { _ in  })
    }
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
}
