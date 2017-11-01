//
//  securityManager.swift
//  SMARTFile
//
//  Created by Tom Rogers on 26/10/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//


import Foundation
import Alamofire

class RequestSecurityManager: SessionManager {
    
    private static var serverTrustPolicies = [
        "www.smartfile-portal.com": serverTrustPolicy
    ]
    
    private static var serverTrustPolicy:ServerTrustPolicy {
        get {
            var publicKey:SecKey?
            
            let pathToCert = Bundle.main.path(forResource: "cert", ofType: "cer")

            let localCertificate:NSData = NSData(contentsOfFile: pathToCert!)!
            
            let cert:SecCertificate = SecCertificateCreateWithData(nil, localCertificate as NSData)!
            
            var trustRef:SecTrust?
            
            let trustManager = SecTrustCreateWithCertificates(cert, SecPolicyCreateBasicX509(), &trustRef)
            
            if let trust = trustRef, trustManager == errSecSuccess {
                publicKey = SecTrustCopyPublicKey(trust)
            }
            return ServerTrustPolicy.pinPublicKeys(publicKeys: [publicKey!],
                                                   validateCertificateChain: true,
                                                   validateHost: true)
        }
    }
    
    init() {
        super.init(configuration: URLSessionConfiguration.default,
                   serverTrustPolicyManager: ServerTrustPolicyManager(policies: RequestSecurityManager.serverTrustPolicies))
        
    }
    
    
    
}
