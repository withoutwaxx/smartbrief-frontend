//
//  UuidGenerator.swift
//  Snofall-trl
//
//  Created by Tom Rogers on 02/03/2017.
//  Copyright © 2017 WithoutWaxx. All rights reserved.
//

import Foundation


class UuidGenerator {
    
    
    
    static func newUuid() -> String {
        
        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        return uuid
    }
    
}
