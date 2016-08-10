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
    
    internal let _mySql = MySQL()
    
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
    
    func connect() ->Bool{
        guard _mySql.connect(host: nil, user: _userName, password: _passWord, db: _database, port: _port, socket: _socket, flag: 0) else {
            Log.info(message : "Failure connecting to data server \(_socket)")
            return false
        }

        guard _mySql.selectDatabase(named: _database) else {
            Log.info(message: "Failure: \(_mySql.errorCode()) \(_mySql.errorMessage())")
            return false
        }
        debugPrint( _mySql.listTables())
        return true
    }
    
    func disconnect() {
        _mySql.close()
    }
    
    func query(_ q : String) throws -> MySQLStmt {
        let sql = MySQLStmt(_mySql)
        if sql.prepare(statement: q) == false {
            throw NSError(domain: String(describing:DBConnector.self), code: 500, userInfo: [AnyHashable(NSLocalizedDescriptionKey) : "Invalid query statement : \(q)"])
        }
        else {
            if sql.execute() == false {
                throw NSError(domain: String(describing: DBConnector.self), code: 500, userInfo: [AnyHashable(NSLocalizedDescriptionKey) : "Invalid query exection : \(q)"])
            }
        }
        return sql
    }
    
}

extension MySQLConnector {
    var dataBase : MySQL {
        return _mySql
    }
}
