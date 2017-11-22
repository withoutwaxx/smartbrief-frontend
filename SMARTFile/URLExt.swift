//
//  URLExt.swift
//  SMARTFile
//
//  Created by Tom Rogers on 21/11/2017.
//  Copyright © 2017 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation


extension NSURL {
    func myFileReferenceURL() -> NSURL? {
        do {
            let fileResourceIdentifier = try self.resourceValues(forKeys:[.fileResourceIdentifierKey])[.fileResourceIdentifierKey]
            struct C {
                var f: UInt64
                var d: UInt64
            }
            guard let data = fileResourceIdentifier as? Data,
                data.count == MemoryLayout<C>.size
                else { return nil }
            let c = data.withUnsafeBytes {
                UnsafeRawPointer($0).load(as: C.self)
            }
            let s = "file:///.file/id=\(c.d).\(c.f)"
            return NSURL(string: s)
        } catch {
            return nil
        }
    }
}
