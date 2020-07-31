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
import XCTest
import SQLite
@testable import BeeGenAPI

final class BeeGenAPITests: XCTestCase {
    func testExample() {
        
        do {
            let connection = try Connection("/Users/marek/beegen/model01/db/model01.db")
            let model = GenModel(connection: connection)
            
            for objRECDATA in try model.fetchObjects(haveType: ObjTypeCode.FIELDDAT.rawValue) {
                print("\nobject: \(objRECDATA.id)")
//                for prp in try objRECDATA.fetchProperties() {
//
//                  //  print("\t\(prp.objid) \(prp.prpType) \(prp.prpMnemonic) \(prp.format) \(prp.value)")
//                    if prp.prpType == PrpTypeCode.FORMAT.rawValue {
//                        print("\t\(prp.objid) \(prp.prpType) \(prp.prpMnemonic) \(prp.format) \(prp.value)")
//                    }
//
//                }
                let prp = try objRECDATA.fetchProperty(haveType: PrpTypeCode.FORMAT.rawValue)
                if prp != nil {
                    
                    print("\t\(prp!.objid) \(prp!.prpType) \(prp!.prpMnemonic) \(prp!.format) \(prp!.value)")
                    
                }
                
                print("\n")
            }
            
            
            
            
           
//            print("\ntest follow many:\n")
//            let connection = try Connection("/Users/marek/beegen/model01/db/model01.db")
//            let model = GenModel(connection: connection)
//            //
//
//            for fromObject in try model.fetchObjects(haveType: ObjTypeCode.HLENT.rawValue) {
//                print("\(fromObject.id)  \(fromObject.name)")
//                for toObject in try fromObject.followAssociationMany(haveType: AscTypeCode.DSCBYA.rawValue) {
//                    print("\t\(toObject.name)")
//                }
//            }
//
//            //
//            print("\ntest follow one:\n")
//            for fromObject in try model.fetchObjects(haveType: ObjTypeCode.ACBLKBSD.rawValue) {
//                print("\(fromObject.id)  \(fromObject.name)")
//                guard let toObject = try fromObject.followAssociationOne(haveType: AscTypeCode.GRPBY.rawValue) else {
//                    print("Cannot find any association of that type.")
//                    return
//                }
//                   print("\t\(toObject.id)  \(toObject.name)")
//
//            }
            
            
            
        } catch  {
            print(error)
        }
        
        
        

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
