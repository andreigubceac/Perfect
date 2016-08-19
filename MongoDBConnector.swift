//
//  MongoDBConnector.swift
//  House-Panic-Server
//
//  Created by Andrei Gubceac on 8/16/16.
//
//

import PerfectLib
import MongoDB

class MongoDBConnector : DataBaseConnectorProtocol {
    
    internal var _db : MongoClient?
    
    func connect() throws {
        _db = try? MongoClient(uri: "mongodb://localhost")
        Log.info(message: "\(_db?.serverStatus())")
    }
    
    func disconnect() {
        _db?.close()
    }
    
    func fetch() {
        
    }
}

/*MongoDB*/
protocol MongoDocument : DataBaseRecord {
    func bson() throws -> BSON
}

/*MongoDB*/

extension MongoDBConnector {
    var dataBase : MongoClient {
        return _db!
    }
    
    
}
