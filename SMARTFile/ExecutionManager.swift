//
//  ConnectionTransportManager.swift
//  Pods
//
//  Created by Tom Rogers on 27/10/2016.
//
//

import Foundation
import Alamofire
import SwiftyJSON


class RequestExecutionManager {
    
    private static var requestSecurityManager:RequestSecurityManager = RequestSecurityManager()
    
    enum MyError: Error {
        case FoundNil(String)
    }
    
 

    static func postCredentials(endpoint:String, email:String, password:String, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()) {
        
        let data = (email + ":" + password).data(using: String.Encoding.utf8)
        let encodedAuth = data!.base64EncodedString()
        
        
        let headers: HTTPHeaders = [
            "Authorization" : "Basic " + encodedAuth
            
        ]
       
        self.requestSecurityManager.request(endpoint, method: .post, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                
            switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if(json["outcome"].boolValue) {
                            User.token = json["token"].stringValue
                            completionHandler(true, "")
                        } else {
                            completionHandler(false, json["message"].stringValue)
                        }
                    }
                    break
                    
                case .failure(let error):
                    if(response.response?.statusCode == 401) {
                        if let value = response.data {
                            let json = JSON(value)
                            completionHandler(false, json["message"].stringValue)
                        }
                    } else {
                        completionHandler(false, "Unable to complete request")
                    }
                    
                    print(error)
                    break
                }
        }
    }
    
    
    static func projectRequest(endpoint:String, completionHandler: @escaping (_ success: Bool, _ message :String, _ projects:[JSON], _ count:[JSON] ) -> ()) {
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + User.token
            
        ]
        
        self.requestSecurityManager.request(endpoint, method: .post, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if(json["outcome"].boolValue) {
                            if(json["exist"].boolValue) {
                                let projects  = json["payload"]["projects"].array
                                let count = json["payload"]["count"].array
                                completionHandler(true, "", projects!, count!)
                            } else {
                                completionHandler(true, "", [], [])
                            }
                            
                        } else {
                            completionHandler(false, json["message"].stringValue, [], [])
                        }
                    }
                    break
                    
                case .failure(let error):
                    if(response.response?.statusCode == 401) {
                        if let value = response.data {
                            let json = JSON(value)
                            completionHandler(false, json["message"].stringValue, [], [])
                        }
                    } else {
                        completionHandler(false, "Unable to complete request", [], [])
                    }
                    
                    print(error)
                    break
                }
        }
    }
    
    
    
    static func getVideos(endpoint:String, completionHandler: @escaping (_ success: Bool, _ message :String, _ videos:[JSON] ) -> ()) {
    
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + User.token
            
        ]
    
        self.requestSecurityManager.request(endpoint, method: .post, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { response in
        
            switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if(json["outcome"].boolValue) {
                            if(json["exist"].boolValue) {
                                let videos  = json["payload"].array
                                completionHandler(true, "", videos!)
                            } else {
                                completionHandler(true, "", [])
                            }
            
                        } else {
                            completionHandler(false, json["message"].stringValue, [])
                        }
                    }
                break
            
            case .failure(let error):
                if(response.response?.statusCode == 401) {
                    if let value = response.data {
                        let json = JSON(value)
                        completionHandler(false, json["message"].stringValue, [])
                    }
                } else {
                    completionHandler(false, "Unable to complete request", [])
                }
            
                print(error)
                break
            }
        }
    }
}
