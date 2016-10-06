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
        if let params = bindedParams {
            _ = params.flatMap { $0 }.map {
                debugPrint("* Binding param \($0) in query \(q)")
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
        if sql.prepare(statement: q) == false {
            throw NSError(domain: String(describing:DataBaseConnectorProtocol.self), code: Int(sql.errorCode()),
                          userInfo: [AnyHashable(NSLocalizedDescriptionKey) : sql.errorMessage()])
        }
        else {
            if sql.execute() == false {
                throw NSError(domain: String(describing: DataBaseConnectorProtocol.self), code: Int(sql.errorCode()),
                              userInfo: [AnyHashable(NSLocalizedDescriptionKey) : sql.errorMessage()])
            }
        }
        return sql
    }
    
    func fetch(_ q : String) throws -> MySQL.Results {
        if _db.query(statement: q) == false {
            throw NSError(domain: String(describing:DataBaseConnectorProtocol.self), code: Int(_db.errorCode()),
                          userInfo: [AnyHashable(NSLocalizedDescriptionKey) : _db.errorMessage()])
        }
        return _db.storeResults()!
    }
    
}

/*MySQL*/
protocol MySQLRecord : DataBaseRecord {
}

extension MySQLRecord {
    
    func mysql_insertKeyValues() -> String {
        var columns = ""
        var values = ""
        for key in type(of : self).db_keys {
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
    
    func mysql_updateKeyValue() -> String {
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

/*MySQL*/
extension MySQLConnector {
    var dataBase : MySQL {
        return _db
    }
    
    func insertRecordQuery(_ r : MySQLRecord) -> String {
        let q = "INSERT INTO \(type(of : r).db_table) \(r.mysql_insertKeyValues());"
        return q
    }
    
    func updateRecordQuery(_ r : MySQLRecord) -> String {
        let q = "UPDATE \(type(of : r).db_table) " +
            "SET \(r.mysql_updateKeyValue()) " +
            "WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]!);"
        return q
    }
    
    func selectRecordQuery(_ r : MySQLRecord) -> String {
        let q = "SELECT * " +
            "FROM \(type(of : r).db_table) " +
            "WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]!);"
        return q
    }
    
    func deleteRecordQuery(_ r : MySQLRecord) -> String {
        let q = "DELETE FROM \(type(of : r).db_table) " +
        "WHERE \(type(of : r).db_identifierKey) = \(r[type(of : r).db_identifierKey]);"
        return q
    }
    
}
