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

extension DataBaseRecord {
    
    func db_insertKeyValues() -> String {
        var columns = ""
        var values = ""
        for key in type(of : self).db_keys {
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
        for key in type(of : self).db_keys {
            if let value = self[key] , key != type(of : self).db_identifierKey {
                q += "\(key)='\(value)',"
            }
        }
        q = q.substring(to: q.index(q.endIndex, offsetBy: -1))
        return q
    }
    
    mutating func updateValues(values : Array<Any>) {
        guard values.count > 0 else {
            return
        }
        var index = 0
        for key in type(of : self).db_keys {
            self[key] = values[index]
            index += 1
        }
    }
}

protocol DataBaseConnectorProtocol  {
    
}

extension DataBaseConnectorProtocol {
    
    func insertRecordQuery(_ r : DataBaseRecord) -> String {
        let q = "INSERT INTO \(type(of : r).db_table) \(r.db_insertKeyValues());"
        return q
    }
    
    func updateRecordQuery(_ r : DataBaseRecord) -> String {
        let q = "UPDATE \(type(of : r).db_table) " +
                "SET \(r.db_updateKeyValue()) " +
                "WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]!);"
        return q
    }
    
    func selectRecordQuery(_ r : DataBaseRecord) -> String {
        let q = "SELECT * " +
                "FROM \(type(of : r).db_table) " +
                "WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]!);"
        return q
    }
    
    func deleteRecordQuery(_ r : DataBaseRecord) -> String {
        let q = "DELETE FROM \(type(of : r).db_table) " +
                "WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]);"
        return q
    }
    
}
