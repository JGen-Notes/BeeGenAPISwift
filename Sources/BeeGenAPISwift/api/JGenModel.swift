//
//  JGenModel.swift
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
/// This object represents a model stored in the container. A container connects
/// to the SQLite database for accessing model data.
///
/// - Author: Marek Stankiewicz
///
/// - Since: 1.0.0
///
public class JGenModel {
    
    let connection: Connection
    
    public var genContainer: JGenContainer
    public var name: String = ""
    public var version: String = ""
    public var schema: String = ""
    
    /// Create table definition for GenObject
    let genModelTable = Table("GenModel")
    let keyColumn = Expression<String>("key")
    let valueColumn = Expression<String>("value")
    
    /// Create table definition for GenObject
    let genObjects = Table("GenObjects")
    let idColumn = Expression<Int64>("id")
    let objTypeColumn = Expression<Int64>("objType")
    let objMnemonicColumn = Expression<String>("objMnemonic")
    let nameColumn = Expression<String>("name")
    
    ///
    /// The class constractor creates an instance of the model object and associates
    /// the model object with the container. Container knows how to access the SQLite
    /// database to retrieve information about objects and their associations and
    /// properties.
    ///
    /// - Parameters:
    ///     - genContainer:  reference to the container storing model
    ///
    public init(containedin genContainer: JGenContainer){
        self.connection = genContainer.connection!
        self.genContainer = genContainer
    }
    
    ///
    /// Retrives from the container the basic information about the model
    /// like name, version and schema level.
    ///
    /// - Returns: Reference to itself.
    ///
    public func retriveModelInfo() -> JGenModel  {
        do {
            for entry in try self.genContainer.connection!.prepare(genModelTable) {
                let key: String = try entry.get(keyColumn)
                let value: String = try entry.get(valueColumn)
                if key == "name" {
                    name = value
                } else  if key == "schema" {
                    schema = value
                } else  if key == "version" {
                    version = value
                }
            }
        } catch  {
            print(error)
        }
        return self
    }
    
    ///
    /// Returns name of the model as given during model creation of the model in the CA Gen.
    ///
    /// - Returns: Name of the model.
    ///
    public func getName() -> String {
        return self.name
    }
    
    ///
    /// Gets the version of the utility creating the Bee Gen Model.
    ///
    /// - Returns: Version level.
    ///
    public func getVersion() -> String {
        return self.name
    }
    
    ///
    /// Gets the schema level of the CA Gen Model used as a source of metadata.
    ///
    /// - Returns: Schema level.
    ///
    public func getSchema() -> String {
        return self.name
    }
    
    ///
    /// Counts number of objects in the model.
    ///
    /// - Returns: Number of objects in the model.
    ///
    public func countObjects() -> Int {
        do {
             let count = try self.connection.scalar(genObjects.count)
                   return count
        } catch {
           print(error)
        }
       return -1
    }
    
    ///
    /// Counts a number of objects of the specified type in the model.
    ///
    /// - Parameters:
    ///     - objMetaType object meta type
    ///
    /// - Returns: Number of objects of the specified type in the model.
    ///
    public func countTypeObjects(having type: ObjMetaType) -> Int {
        do {
            let count = try self.connection.scalar(genObjects.filter(objTypeColumn == type.rawValue).count)
                   return count
        } catch {
           print(error)
        }
       return -1
    }
    
    ///
    /// Finds the object in the model having a specified object id.
    ///
    /// - Parameters:
    ///     - id unique identifier of the object
    ///
    /// - Returns: Object having specified identifier or `null` if not found
    ///
    public func findObjectById(haveId: Int64) -> JGenObject? {
        do {
            for object in try self.connection.prepare(genObjects.where(idColumn == haveId)) {
                return JGenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn))
            }
        } catch  {
            //throw GenAPIException.someProblemAccessingModel(description: error.localizedDescription)
            print(error)
        }
        return nil
    }
    
    ///
    /// Finds all objects with the matching object type code.
    ///
    /// - Parameters:
    ///     - objMetaType type of object to be selected
    ///
    /// - Returns: Array of objects matching the specified type.
    ///
    public func findTypeObjects(haveType: ObjMetaType) -> Array<JGenObject> {
        var array = Array<JGenObject>()
        do {
            for object in try self.connection.prepare(genObjects.where(objTypeColumn == haveType.rawValue)) {
                array.append(JGenObject(connection: self.connection,id: try object.get(idColumn), objType: try  object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn)))
            }
        } catch  {
            //throw GenAPIException.someProblemAccessingModel(description: error.localizedDescription)
            print(error)
        }
        return array
    }
    
    ///
    /// Finds and returns a list of objects having the specified  object type, property type and name.
    ///
    /// - Parameters:
    ///     - objMetaType type of object
    ///     - prpMetaType type of property
    ///     - name name given to the object.
    ///
    /// - Returns: Array of objects matching the specified type, property type, and speficfied name.
    ///
    public func findNamedObjects(havetype: ObjMetaType, haveTypePrp: PrpMetaType, havename: String) -> Array<JGenObject> {
        var array = Array<JGenObject>()
        do {
            // TODO
            for object in try self.connection.prepare(genObjects.where(objTypeColumn == havetype.rawValue && nameColumn == havename)) {
                array.append(JGenObject(connection: self.connection, id: try object.get(idColumn), objType: try object.get(objTypeColumn), objMnemonic: try object.get(objMnemonicColumn), name: try object.get(nameColumn)))
            }
        } catch  {
            //throw GenAPIException.someProblemAccessingModel(description: error.localizedDescription)
            print(error)
        }
        return array
    }
    
    
    
}
