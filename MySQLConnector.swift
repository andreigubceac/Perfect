//
//  MySQLConnector.swift
//
//  Created by Andrei Gubceac on 8/9/16.
//
//

import PerfectLib
import Foundation
import MySQL

class MySQLConnector : DataBaseConnectorProtocol {
    
    internal let _db = MySQL()
    
    private var _userName   : String!
    private var _passWord   : String!
    private var _socket     : String!
    private var _port       : UInt32!
    private var _database   : String!
    
    init(userName : String, password : String, socket : String, port : UInt32, database : String) {
        _userName   = userName
        _passWord   = password
        _socket     = socket
        _port       = port
        _database   = database
    }
    
    deinit {
        disconnect()
    }
    
    func connect() throws {
        guard _db.connect(host: nil, user: _userName, password: _passWord, db: _database, port: _port, socket: _socket, flag: 0) else {
            Log.info(message : "Failure connecting to data server \(_socket)")
            throw NSError(domain: String(describing:DataBaseConnectorProtocol.self), code: Int(_db.errorCode()),
                          userInfo: [AnyHashable(NSLocalizedDescriptionKey) : _db.errorMessage()])
        }

        guard _db.selectDatabase(named: _database) else {
            Log.info(message: "Failure: \(_db.errorCode()) \(_db.errorMessage())")
            throw NSError(domain: String(describing:DataBaseConnectorProtocol.self), code: Int(_db.errorCode()),
                          userInfo: [AnyHashable(NSLocalizedDescriptionKey) : _db.errorMessage()])
        }
    }
    
    func disconnect() {
        _db.close()
    }
    
    func query(_ q : String, bindedParams : [AnyHashable]? = nil) throws -> MySQLStmt {
        let sql = MySQLStmt(_db)
        guard sql.prepare(statement: q) else {
            throw NSError(domain: String(describing:DataBaseConnectorProtocol.self), code: Int(sql.errorCode()),
                          userInfo: [AnyHashable(NSLocalizedDescriptionKey) : sql.errorMessage()])
        }
        if let params = bindedParams {
            _ = params.flatMap { $0 }.map {
                if $0 is String {
                    sql.bindParam($0 as! String)
                }
                else if $0 is Int {
                    sql.bindParam($0 as! Int)
                }
                else if $0 is Double {
                    sql.bindParam($0 as! Double)
                }
                else if $0 is UInt64 {
                    sql.bindParam($0 as! UInt64)
                }
            }
        }
        guard sql.execute() else {
            throw NSError(domain: String(describing: DataBaseConnectorProtocol.self), code: Int(sql.errorCode()),
                          userInfo: [AnyHashable(NSLocalizedDescriptionKey) : sql.errorMessage()])
        }
        return sql
    }
    
    func fetch(_ q : String) throws -> MySQL.Results {
        guard _db.query(statement: q) else {
            throw NSError(domain: String(describing:DataBaseConnectorProtocol.self), code: Int(_db.errorCode()),
                          userInfo: [AnyHashable(NSLocalizedDescriptionKey) : _db.errorMessage()])
        }
        return _db.storeResults()!
    }
    
}

/*MySQL*/
protocol MySQLRecord : DataBaseRecord {}

extension MySQLRecord {
        
    func mysql_insert(keys : [AnyHashable]? = nil) -> String {
        var columns = ""
        var values = ""
        let keys = keys ?? type(of : self).db_keys
        for key in keys {
            if key == Self.db_identifierKey {
                continue
            }
            columns += "\(key),"
            values += "?,"
        }
        columns = columns.substring(to: columns.index(columns.endIndex, offsetBy: -1))
        values = values.substring(to: values.index(values.endIndex, offsetBy: -1))
        return "(\(columns)) VALUES (\(values))"
    }
    
    func mysql_update(keys : [AnyHashable]? = nil) -> String {
        var q = ""
        let keys = keys ?? type(of : self).db_keys
        for key in keys {
            if key != type(of : self).db_identifierKey {
                q += "\(key)=?,"
            }
        }
        q = q.substring(to: q.index(q.endIndex, offsetBy: -1))
        return q
    }
    
}

/*MySQL*/
extension MySQLConnector {
    var dataBase : MySQL {
        return _db
    }
    
    func insertRecordQuery(_ r : MySQLRecord, bindParams : [String]? = nil) -> String {
        let q = "INSERT INTO \(type(of : r).db_table) \(r.mysql_insert(keys: bindParams));"
        return q
    }
    
    func updateRecordQuery(_ r : MySQLRecord, bindParams : [String]? = nil) -> String {
        let q = "UPDATE \(type(of : r).db_table) " +
            "SET \(r.mysql_update(keys: bindParams)) " +
            "WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]!);"
        return q
    }
    
    func selectRecordQuery(_ r : MySQLRecord, excludeParams: [String]? = nil) -> String {
        var keys = type(of : r).db_keys as! Array<String>
        for param in excludeParams ?? [] {
            if let index = keys.index(of: param) {
                keys.remove(at: index)
            }
        }
        let q = "SELECT \(excludeParams != nil ? keys.joined(separator: ",") : "*") " +
            "FROM \(type(of : r).db_table) " +
            "WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]!);"
        return q
    }
    
    func deleteRecordQuery(_ r : MySQLRecord) -> String {
        return "DELETE FROM \(type(of : r).db_table) WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]);"
    }
    
}
