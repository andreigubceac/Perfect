//
//  DataBaseConnector.swift
//
//  Created by Andrei Gubceac on 8/9/16.
//
//

import Foundation

protocol DataBaseRecord {
    
    static var db_table : String { get }
    static var db_identifierKey : AnyHashable { get }
    static var db_keys : Array<AnyHashable> { get }
    
    subscript(key: AnyHashable) -> Any? { get set }
}

extension DataBaseRecord {
    func toDictionary(element: [Any]) -> Dictionary<AnyHashable, Any> {
        var dict = Dictionary<AnyHashable, Any>()
        for key in type(of : self).db_keys {
            if let index = type(of : self).db_keys.index(of: key), index < element.count {
                dict[key] = element[index]
            }
        }
        return dict
    }
}

protocol DataBaseConnectorProtocol  {
    func connect() throws
    func disconnect()
}

let recordNotFoundError = NSError(domain: String(describing : DataBaseConnectorProtocol.self), code: 404, userInfo: [AnyHashable(NSLocalizedDescriptionKey) : "Not found"])
