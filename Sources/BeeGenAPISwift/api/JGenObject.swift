//
//  JGenObject.swift
//  
//
//  Created by Marek Stankiewicz on 14/09/2020.
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

///
/// This model object represents a single element of the model. Model
/// can own any number of objects of many different types. Each object
/// may have number of its properties and associations with other
/// objects. You can follow associations discovering many other objects.
/// The model functionality allows you to select a number of objects
/// of your interest and they can be a starting point to the navigation
/// thru the model.
///
/// - Author: Marek Stankiewicz
///
/// - Since: 1.0.0
///
public class JGenObject {
    
    private let connection: Connection
    public let id : Int64
    public let objType: Int64
    public let objMnemonic: String
    public let name: String
    
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
    public func findAssociationMany(haveType: AscMetaType) throws -> Array<JGenObject> {
        var array = Array<JGenObject>()
        for association in try self.connection.prepare(genAssociations.where(fromObjidColumn == self.id && ascTypeColumn == haveType.rawValue)) {
             if try association.get(cardColumn) != Cardinality.many.rawValue {
                 //throw GenAPIException.associationNotCardinalityMany(objid: self.id, ascType: haveType.rawValue)
             }
             for object in try self.connection.prepare(genObjects.where(idColumn == association.get(toObjidColumn))) {
                 array.append(JGenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn)))
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
    public func findAssociationOne(haveType: AscMetaType) throws -> JGenObject? {
        for association in try self.connection.prepare(genAssociations.where(fromObjidColumn == self.id && ascTypeColumn == haveType.rawValue)) {
            if try association.get(cardColumn) != Cardinality.one.rawValue {
                //throw GenAPIException.associationNotCardinalityOne(objid: self.id, ascType: haveType)
                 return nil
            }
            for object in try self.connection.prepare(genObjects.where(idColumn == association.get(toObjidColumn))) {
                return JGenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn))
            }
        }
        return nil
    }
    
    /// The method finds a character property of the specified type for this object.
    /// It returns `?` in case of the object for some reason does not have the property
    /// of the specified type or value existing property is not character type.
    /// - Parameters:
    ///
    ///   - haveType: A type of property.
    ///
    /// - Returns: The value of property or `?` if not found.
    ///
    public func findCharacterProperty(haveType: PrpMetaType) throws -> String {
        for property in try self.connection.prepare(genProperties.where(objidColumn == self.id && prpTypeColumn == haveType.rawValue)) {
            let format = try property.get(formatColumn)
            if format == PrpFormat.CHAR.rawValue {
                return try property.get(valueColumn)
            }
        }
        return "?"
    }
    
    /// The method finds a text property of the specified type for this object.
    /// It returns emty string in case of the object for some reason does not have the property
    /// of the specified type or value existing property is not character type.
    /// - Parameters:
    ///
    ///   - haveType: A type of property.
    ///
    /// - Returns: The value of property or empty staing if not found.
    ///
    public func findTextProperty(haveType: PrpMetaType) throws -> String {
        for property in try self.connection.prepare(genProperties.where(objidColumn == self.id && prpTypeColumn == haveType.rawValue)) {
            let format = try property.get(formatColumn)
            if format == PrpFormat.TEXT.rawValue ||
                format == PrpFormat.LOADNAME.rawValue ||
                format == PrpFormat.NAME.rawValue
                {
                return try property.get(valueColumn)
            }
        }
        return ""
    }
    
    /// The method finds a number property of the specified type for this object.
    /// It returns `0` in case of the object for some reason does not have the property
    /// of the specified type or value existing property is not character type.
    /// - Parameters:
    ///
    ///   - haveType: A type of property.
    ///
    /// - Returns: The value of property or `0`if not found.
    ///
    public func findNumberProperty(haveType: PrpMetaType) throws -> Int {
        for property in try self.connection.prepare(genProperties.where(objidColumn == self.id && prpTypeColumn == haveType.rawValue)) {
            let format = try property.get(formatColumn)
            if format == PrpFormat.INT.rawValue ||
                format == PrpFormat.SINT.rawValue
                {
                    return try Int.init(property.get(valueColumn))!
            }
        }
        return 0
    }
}
