//
//  DataBaseConnector.swift
//
//  Created by Andrei Gubceac on 8/9/16.
//
//

import Foundation

protocol DataBaseRecord {
    
    var db_table : String { get }
    var db_identifierKey : String { get }
    var db_keys : Array<String> { get }
    subscript(key: String) -> Any? { get set }
}

extension DataBaseRecord {
    
    func db_insertKeyValues() -> String {
        var columns = ""
        var values = ""
        for key in db_keys {
            if let value = self[key] {
                columns += "\(key),"
                values += "'\(value)',"
            }
        }
        columns = columns.substring(to: columns.index(columns.endIndex, offsetBy: -1))
        values = values.substring(to: values.index(values.endIndex, offsetBy: -1))
        return "(\(columns)) VALUES (\(values))"
    }
    
    func db_updateKeyValue() -> String {
        var q = ""
        for key in db_keys {
            if let value = self[key] , key != db_identifierKey {
                q += "\(key)='\(value)',"
            }
        }
        q = q.substring(to: q.index(q.endIndex, offsetBy: -1))
        return q
    }
}

protocol DataBaseConnectorProtocol  {
    
}

extension DataBaseConnectorProtocol {
    
    func insertRecordQuery(_ r : DataBaseRecord) -> String {
        let q = "INSERT INTO \(r.db_table) \(r.db_insertKeyValues());"
        return q
    }
    
    func updateRecordQuery(_ r : DataBaseRecord) -> String {
        let q = "UPDATE \(r.db_table) " +
                "SET \(r.db_updateKeyValue()) " +
                "WHERE \(r.db_identifierKey) = \(r[r.db_identifierKey]!);"
        return q
    }
    
    func deleteRecordQuery(_ r : DataBaseRecord) -> String {
        let q = "DELETE \(r.db_table) " +
                "WHERE \(r.db_identifierKey) = \(r[r.db_identifierKey]);"
        return q
    }
    
}
