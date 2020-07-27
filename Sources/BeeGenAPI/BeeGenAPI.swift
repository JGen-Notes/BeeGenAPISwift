//
//  BeeGenAPI.swift
//
//
//  Created by Marek Stankiewicz on 23/07/2020.
//

import Foundation
import SQLite

public struct GenModel {
    
    fileprivate let connection: Connection
    
    // Create table GenObjects
   let genObjects = Table("GenObjects")
   let idColumn = Expression<Int64>("id")
   let objTypeColumn = Expression<Int64>("objType")
   let objMnemonicColumn = Expression<String>("objMnemonic")
   let nameColumn = Expression<String>("name")
    
    public init(connection: Connection) {
        self.connection = connection
    }
    
    public func fetchObject(haveId: Int64) throws -> GenObject? {
        //var array = Array<GenObject>()
        do {
            for object in try self.connection.prepare(genObjects.where(idColumn == haveId)) {
                return GenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn))
            }
            return nil
        } catch  {
            throw GenAPIException.someProblemAccessingModel(description: error.localizedDescription)
        }
    }
    
    public func fetchObjects(haveType: Int64) throws -> Array<GenObject> {
        var array = Array<GenObject>()
        do {
            for object in try self.connection.prepare(genObjects.where(objTypeColumn == haveType)) {
                array.append(GenObject(connection: self.connection,id: try object.get(idColumn), objType: try  object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn)))
            }
        } catch  {
            throw GenAPIException.someProblemAccessingModel(description: error.localizedDescription)
        }
        return array
    }
    
    public func fetchObject(havetype: Int64, havename: String) throws -> GenObject? {
        do {
            for object in try self.connection.prepare(genObjects.where(objTypeColumn == havetype && nameColumn == havename)) {
                return GenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn))
            }
            return nil
        } catch  {
            throw GenAPIException.someProblemAccessingModel(description: error.localizedDescription)
        }
    }
}

public struct GenObject {
    
    public let id : Int64
    public let objType: Int64
    public let objMnemonic: String
    public let name: String
    
    fileprivate let connection: Connection
    
     // Create table GenObjects
    let genObjects = Table("GenObjects")
    let idColumn = Expression<Int64>("id")
    let objTypeColumn = Expression<Int64>("objType")
    let objMnemonicColumn = Expression<String>("objMnemonic")
    let nameColumn = Expression<String>("name")
    
    // Create table GenAssociations
    let genAssociations = Table("GenAssociations")
    let fromObjidColumn = Expression<Int64>("fromObjid")
    let ascTypeColumn = Expression<Int64>("ascType")
    let toObjidColumn = Expression<Int64>("toObjid")
    let inverseAscTypeColumn = Expression<Int64>("inverseAscType")
    let ascMnemonicColumn = Expression<String>("ascMnemonic")
    let cardColumn = Expression<String?>("card")
    let directionColumn = Expression<String?>("direction")
    
    public  init(connection: Connection, id: Int64, objType: Int64, objMnemonic: String, name: String) {
        self.connection = connection
        self.id = id
        self.objType = objType
        self.objMnemonic = objMnemonic
        self.name = name
    }
    
    public func followAssociationMany(haveType: Int64) throws -> Array<GenObject> {
        var array = Array<GenObject>()
        for association in try self.connection.prepare(genAssociations.where(fromObjidColumn == self.id && ascTypeColumn == haveType)) {
            if try association.get(cardColumn) != Cardinality.many.rawValue {
                throw GenAPIException.associationNotCardinalityMany(objid: self.id, ascType: haveType)
            }
            for object in try self.connection.prepare(genObjects.where(idColumn == association.get(toObjidColumn))) {
                array.append(GenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn)))
            }           
        }
         return array
    }
    
    public func followAssociationOne(haveType: Int64) throws -> GenObject? {
        
      //  print("from: \(self.id), asc: \(haveType)")
        
        for association in try self.connection.prepare(genAssociations.where(fromObjidColumn == self.id && ascTypeColumn == haveType)) {
           // print("from: \(association)")
            //print(Cardinality.one.rawValue)
            if try association.get(cardColumn) != Cardinality.one.rawValue {
                throw GenAPIException.associationNotCardinalityOne(objid: self.id, ascType: haveType)
            }
         //   print("association")
            for object in try self.connection.prepare(genObjects.where(idColumn == association.get(toObjidColumn))) {
                return GenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn))
            }
        }
        return nil
    }
     
}


public enum GenAPIException : Error {
    
    case someProblemAccessingModel(description: String)
    case unexpectedDublicateFound(objid: Int64, objType: ObjTypeCode, name: String)
    case associationNotCardinalityOne(objid: Int64, ascType: Int64)
    case associationNotCardinalityMany(objid: Int64, ascType: Int64)
    
}

public enum Cardinality: String {
    
    case many = "M"
    case one = "1"
    
}

