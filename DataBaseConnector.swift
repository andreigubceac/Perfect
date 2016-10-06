//
//  DataBaseConnector.swift
//
//  Created by Andrei Gubceac on 8/9/16.
//
//

import Foundation

protocol DataBaseRecord {
    
    static var db_table : String { get }
    static var db_identifierKey : String { get }
    static var db_keys : Array<String> { get }
    
    subscript(key: String) -> Any? { get set }
}

protocol DataBaseConnectorProtocol  {
    func connect() throws
    func disconnect()
}

let recordNotFoundError = NSError(domain: String(describing : DataBaseConnectorProtocol.self), code: 404, userInfo: [AnyHashable(NSLocalizedDescriptionKey) : "Not found"])
