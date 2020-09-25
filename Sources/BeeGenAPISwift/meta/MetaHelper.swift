//
//  Meta.swift
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
/// 
///
/// - Author: Marek Stankiewicz
///
/// - Since: 1.0.0
///
public class MetaHelper {

    let connection: Connection
    
    //public let genContainer: JGenContainer
    
    /// Create table definition for GenMetaProperties
    let genMetaProperties = Table("GenMetaProperties")
    let objTypeColumn = Expression<Int64>("objType")
    let prpTypeColumn = Expression<Int64>("prpType")
    let prpMnemonicColumn = Expression<String>("prpMnemonic")
    let formatColumn = Expression<String>("format")
    let lengthColumn = Expression<Int64>("length")
    let defaultNumberColumn = Expression<Int64>("defaultInt")
    let defaultTextColumn = Expression<String>("defaultText")
    let defaultCharColumn = Expression<String>("defaultChar")
    
    /// Create table definition for GenMetaAssociations
    let genMetaAssociations = Table("GenMetaAssociations")
    let fromObjTypeColumn = Expression<Int64>("fromObjType")
    let ascTypeColumn = Expression<Int64>("ascType")
    let ascMnemonicColumn = Expression<String>("ascMnemonic")
    let directionColumn = Expression<String>("direction")
    let inverseAdcTypeColumn = Expression<Int64>("inverseAdcType")
    let optionalityColumn = Expression<String>("optionality")
    let cardColumn = Expression<String>("card")
    let orderedColumn = Expression<String>("ordered")
    
    public init(connection: Connection) {
        self.connection = connection
    }
    
    public func getDefaultCharProperty(hasObjType: ObjMetaType, hasPrpType: PrpMetaType) -> String {
        do {
            for property in try self.connection.prepare(genMetaProperties.where(objTypeColumn == hasObjType.rawValue && prpTypeColumn == hasPrpType.rawValue)) {
                return try property.get(defaultCharColumn)
            }
        } catch {
            print(error)
        }
        return ""
    }
    
    public func getDefaultTextProperty(hasObjType: ObjMetaType, hasPrpType: PrpMetaType) -> String {
        do {
            for property in try self.connection.prepare(genMetaProperties.where(objTypeColumn == hasObjType.rawValue && prpTypeColumn == hasPrpType.rawValue)) {
                return try property.get(defaultTextColumn)
            }
        } catch {
            print(error)
        }
        return ""
    }
    
    public func getDefaultNumberProperty(hasObjType: ObjMetaType, hasPrpType: PrpMetaType) -> Int64 {
        do {
            for property in try self.connection.prepare(genMetaProperties.where(objTypeColumn == hasObjType.rawValue && prpTypeColumn == hasPrpType.rawValue)) {
                return try property.get(defaultNumberColumn)
            }
        } catch {
            print(error)
        }
        return -1
    }
    
     
    public func getAssociationCodes(hasObjType: ObjMetaType) -> Array<AscMetaType>{
        var array = Array<AscMetaType>()
        do {
            for association in try self.connection.prepare(genMetaAssociations.where(fromObjTypeColumn == hasObjType.rawValue)) {
                array.append(AscMetaType.init(rawValue: try association.get(ascTypeColumn))!)
            }
        } catch {  
            print(error)
        }
        return array
    }
    
    public func getPropertyCodes(hasObjType: ObjMetaType) -> Array<PrpMetaType>{
        var array = Array<PrpMetaType>()
        do {
            for property in try self.connection.prepare(genMetaProperties.where(objTypeColumn == hasObjType.rawValue)) {
                array.append(PrpMetaType.init(rawValue: try property.get(prpTypeColumn))!)
            }
        } catch {
            print(error)
        }
        return array
    }
    
    public func isAssociationOnetoOne(hasObjType: ObjMetaType, hasAscType: AscMetaType) -> Bool {
        do {
            for association in try self.connection.prepare(genMetaAssociations.where(fromObjTypeColumn == hasObjType.rawValue && ascTypeColumn == hasAscType.rawValue)) {
                if try association.get(cardColumn) == "1" {
                    return true
                } else {
                    return false
                }
            }
        } catch {
            print(error)
        }
        return false
    }
    
    public func isAssociationForward(hasObjType: ObjMetaType, hasAscType: AscMetaType) -> Bool {
        do {
            for association in try self.connection.prepare(genMetaAssociations.where(fromObjTypeColumn == hasObjType.rawValue && ascTypeColumn == hasAscType.rawValue)) {
                if try association.get(directionColumn) == "F" {
                    return true
                } else {
                    return false
                }
            }
        } catch {
            print(error)
        }
        return false
    }
    
    public func isAssociationOptional(hasObjType: ObjMetaType, hasAscType: AscMetaType) -> Bool {
         do {
             for association in try self.connection.prepare(genMetaAssociations.where(fromObjTypeColumn == hasObjType.rawValue && ascTypeColumn == hasAscType.rawValue)) {
                 if try association.get(optionalityColumn) == "Y" {
                     return true
                 } else {
                     return false
                 }
             }
         } catch {
             print(error)
         }
         return false
     }
    
    public func isAssociationOrdered(hasObjType: ObjMetaType, hasAscType: AscMetaType) -> Bool {
         do {
             for association in try self.connection.prepare(genMetaAssociations.where(fromObjTypeColumn == hasObjType.rawValue && ascTypeColumn == hasAscType.rawValue)) {
                 if try association.get(orderedColumn) == "Y" {
                     return true
                 } else {
                     return false
                 }
             }
         } catch {
             print(error)
         }
         return false
     }

}
