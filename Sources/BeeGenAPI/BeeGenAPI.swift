//
//  BeeGenAPI.swift
//
//
//  Created by Marek Stankiewicz on 06/07/2020.
//  Copyright © 2020 JGen. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import SQLite

/// This structure represents an entire Bee Gen Model in the memory provides a starting points
/// for any navigation thru the contents of the model.
public struct GenModel {
    
    fileprivate let connection: Connection
    
   /// Create table definition for GenObject
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

/// This structure represents an entire GenObject in the memory and provides
/// a number of function helping extracting information about associations and properties.
public struct GenObject {
    
    public let id : Int64
    public let objType: Int64
    public let objMnemonic: String
    public let name: String
    
    fileprivate let connection: Connection
    
    /// Create table definition for GenObject
    let genObjects = Table("GenObjects")
    let idColumn = Expression<Int64>("id")
    let objTypeColumn = Expression<Int64>("objType")
    let objMnemonicColumn = Expression<String>("objMnemonic")
    let nameColumn = Expression<String>("name")
    
    /// Create table definition for GenAssociations
    let genAssociations = Table("GenAssociations")
    let fromObjidColumn = Expression<Int64>("fromObjid")
    let ascTypeColumn = Expression<Int64>("ascType")
    let toObjidColumn = Expression<Int64>("toObjid")
    let inverseAscTypeColumn = Expression<Int64>("inverseAscType")
    let ascMnemonicColumn = Expression<String>("ascMnemonic")
    let cardColumn = Expression<String?>("card")
    let directionColumn = Expression<String?>("direction")
    let seqnoColumn = Expression<String?>("seqno")
    
    /// Create table definition for GenProperties
    let genProperties = Table("GenProperties")
    let objidColumn = Expression<Int64>("objid")
    let prpTypeColumn = Expression<Int64>("prpType")
    let prpMnemonicColumn = Expression<String>("mnemonic")
    let formatColumn = Expression<String>("format")
    let valueColumn = Expression<String>("value")
    
    
    
    public  init(connection: Connection, id: Int64, objType: Int64, objMnemonic: String, name: String) {
        self.connection = connection
        self.id = id
        self.objType = objType
        self.objMnemonic = objMnemonic
        self.name = name
    }
    
    /// Fetching associated objects associated with the itself.
    ///
    /// - Parameters:
    ///
    ///   - haveType: A type of association.
    ///
    /// - Returns: The array of objects associated with itself of the specified type.
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
    
    /// Fetching associated single object associated with the itself.
    ///
    /// - Parameters:
    ///
    ///   - haveType: A type of association.
    ///
    /// - Returns: The object associated with itself of the specified type or nil if not found.
    public func followAssociationOne(haveType: Int64) throws -> GenObject? {
       for association in try self.connection.prepare(genAssociations.where(fromObjidColumn == self.id && ascTypeColumn == haveType)) {
           // print("from: \(association)")
            //print(Cardinality.one.rawValue)
            if try association.get(cardColumn) != Cardinality.one.rawValue {
                throw GenAPIException.associationNotCardinalityOne(objid: self.id, ascType: haveType)
            }
            for object in try self.connection.prepare(genObjects.where(idColumn == association.get(toObjidColumn))) {
                return GenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn))
            }
        }
        return nil
    }
    
    /// Fetching  properties of itself.
    ///
    ///
    /// - Returns: The array of property of itself.
    public func fetchProperties() throws -> Array<GenProperty> {
        var array = Array<GenProperty>()
        for property in try self.connection.prepare(genProperties.where(objidColumn == self.id)) {
            array.append(GenProperty(connection: connection, objid: try property.get(objidColumn), prpType: try property.get(prpTypeColumn), prpMnemonic: try property.get(prpMnemonicColumn), format: try property.get(formatColumn), value: try property.get(valueColumn)))
        }
        return array
    }
    
    /// Fetching specific single property of itself.
    ///
    /// - Parameters:
    ///
    ///   - haveType: A type of property.
    ///
    /// - Returns: The spefified property of itself or nil if not found.
    public func fetchProperty(haveType: Int64) throws -> GenProperty? {
        for property in try self.connection.prepare(genProperties.where(objidColumn == self.id && prpTypeColumn == haveType)) {
            return GenProperty(connection: connection, objid: try property.get(objidColumn), prpType: try property.get(prpTypeColumn), prpMnemonic: try property.get(prpMnemonicColumn), format: try property.get(formatColumn), value: try property.get(valueColumn))
        }
        return nil
    }
     
}

/// This structure   contains all infromation about a single property.
public struct GenProperty {
    
    public let objid : Int64
    public let prpType: Int64
    public let prpMnemonic: String
    public let format: String
    public let value: String
    
    fileprivate let connection: Connection
    
    /// Create table definition for GenProperties
    let genProperties = Table("GenProperties")
    let objidColumn = Expression<Int64>("objid")
    let prpTypeColumn = Expression<Int64>("prpType")
    let prpMnemonicColumn = Expression<String>("mnemonic")
    let formatColumn = Expression<String>("format")
    let valueColumn = Expression<String>("value")
    
    public  init(connection: Connection, objid: Int64, prpType: Int64, prpMnemonic: String, format: String, value: String) {
        self.connection = connection
        self.objid = objid
        self.prpType = prpType
        self.prpMnemonic = prpMnemonic
        self.format = format
        self.value = value
    }
    
    public func getNumberValue() throws -> Int? {
        switch format {
        case PrpFormat.INT.rawValue:
            return Int(value)
        case PrpFormat.SINT.rawValue:
            return Int(value)
        default:
            throw GenAPIException.propertyNotNumber(objid: objid, prpType: prpType)
        }
       
    }
    
    public func getTextValue() throws -> String? {
        return value
    }
    
}


public enum GenAPIException : Error {
    
    case someProblemAccessingModel(description: String)
    case unexpectedDublicateFound(objid: Int64, objType: ObjTypeCode, name: String)
    case associationNotCardinalityOne(objid: Int64, ascType: Int64)
    case associationNotCardinalityMany(objid: Int64, ascType: Int64)
    case propertyNotNumber(objid: Int64, prpType: Int64)
}

public enum Cardinality: String {
    
    case many = "M"
    case one = "1"
    
}

