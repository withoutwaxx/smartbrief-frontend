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
import JWTDecode


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
                            print(json["token"].stringValue)
                            User.token = json["token"].stringValue
                            do {
                                let jwt = try decode(jwt: User.token)
                                User.id = jwt.body["id"] as! String
                            } catch {
                                print(error.localizedDescription)
                                
                            }
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
    
    
    
    static func updateCredentials(endpoint:String, oldPassword:String, newPassword:String, completionHandler: @escaping (_ success: Bool, _ message :String) -> ()) {
        
        let data = (oldPassword + ":" + newPassword).data(using: String.Encoding.utf8)
        let encodedAuth = data!.base64EncodedString()
        
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + User.token,
            "Update" : encodedAuth
        
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
                            do {
                                let jwt = try decode(jwt: User.token)
                                User.id = jwt.body["id"] as! String
                            } catch {
                                print(error.localizedDescription)
                                
                            }
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
    
    
    
    static func videoRequest(endpoint:String, completionHandler: @escaping (_ success: Bool, _ message :String, _ videos:[JSON] ) -> ()) {
    
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
    
    
    
    static func newVideo(endpoint:String, completionHandler: @escaping (_ success: Bool) -> ()) {
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + User.token
            
        ]
        
        
        let serialQ = DispatchQueue.global(qos: .utility)
        
        self.requestSecurityManager.request(endpoint, method: .post, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: serialQ) { response in
                
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        if(json["outcome"].boolValue) {
                            completionHandler(true)
                            
                        } else {
                            completionHandler(false)
                        }
                    }
                    break
                    
                case .failure(let error):
                    if(response.response?.statusCode == 401) {
                        completionHandler(false)
                    
                    } else {
                        completionHandler(false)
                    }
                    
                    print(error)
                    break
                }
        }
    }
}
