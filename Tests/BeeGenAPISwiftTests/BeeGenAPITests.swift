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
@testable import BeeGenAPISwift

final class BeeGenAPITests: XCTestCase {
    
    let containerPath = "/Users/marek/beegen01.ief/bee/BEEGEN01.db"
    let version = "0.5"
    let schema = "9.2.A6"
    
    func testSampleApplication() {
        let containerPath = "/Users/marek/beegen01.ief/bee/BEEGEN01.db"
        let genContainer = JGenContainer()
        let genModel = genContainer.connect(to: containerPath)
        print("List of action blocks in the model: " + genModel!.getName() + ", Using schema level: "
                + genModel!.getSchema() + "\n")
        for genObject in genModel!.findTypeObjects(haveType: ObjMetaType.ACBLKBSD) {
            print("\tAction block name: " + genObject.findTextProperty(haveType: PrpMetaType.NAME) + ", having id: \(genObject.id)"
            )
        }
        genContainer.disconnect();
        print("\nCompleted.");
    }
    
    func testContainer() {
        let genContainer = JGenContainer()
        let genModel = genContainer.connect(to: containerPath)
        assert(genContainer.getModel() === genModel)
        assert(genContainer.getModel()?.name == genModel?.name)
        assert(genModel !== nil)
        assert(genContainer.getContainerLocation() == containerPath)
        assert(genModel?.name == "BEEGEN01")
        assert(genModel?.version == version)
        assert(genModel?.schema == schema)
    }
    
    func testModel() {
        let genContainer = JGenContainer()
        let genModel = genContainer.connect(to: containerPath)
        //print(genModel!.countObjects())
        assert(genModel!.countObjects() == 1228)
        //print(genModel!.countTypeObjects(having: ObjMetaType.ACBLKBSD))
        assert(genModel!.countTypeObjects(having: ObjMetaType.ACBLKBSD) == 5)
        //print(genModel!.findObjectById(haveId: 22020096)?.name)
        assert(genModel!.findObjectById(haveId: 22020096)?.name == "PERSON_CREATE")
        //print(genModel!.findTypeObjects(haveType: ObjMetaType.ACBLKBSD.rawValue).count)
        assert(genModel!.findTypeObjects(haveType: ObjMetaType.ACBLKBSD).count == 5)
        //print(genModel!.findNamedObjects(havetype: ObjMetaType.ACBLKBSD.rawValue, haveTypePrp: PrpMetaType.NAME.rawValue, havename: "PERSON_CREATE").count)
        assert(genModel!.findNamedObjects(havetype: ObjMetaType.ACBLKBSD, haveTypePrp: PrpMetaType.NAME, havename: "PERSON_CREATE").count == 1)
    }
    
    func testObject() {
        let genContainer = JGenContainer()
        let genModel = genContainer.connect(to: containerPath)
        let genObject = genModel?.findObjectById(haveId: 22020096)
        //print(genObject!.findCharacterProperty(haveType: PrpMetaType.PASSGLOB))
        assert(genObject!.findCharacterProperty(haveType: PrpMetaType.PASSGLOB) == "M")
        //print(genObject!.findTextProperty(haveType: PrpMetaType.NAME))
        assert(genObject!.findTextProperty(haveType: PrpMetaType.NAME) == "PERSON_CREATE")
        //print(genObject!.findNumberProperty(haveType: PrpMetaType.OPCODE))
        assert(genObject!.findNumberProperty(haveType: PrpMetaType.OPCODE) == 21)
        //print(genObject!.findNumberProperty(haveType: PrpMetaType.CEID))
        assert(genObject!.findNumberProperty(haveType: PrpMetaType.CEID) == 1049)
        let array = try genObject!.findAssociationMany(haveType: AscMetaType.USESEXST)
        //        for obj in array {
        //            print("\(obj.id)" + " " + obj.objMnemonic)
        //        }
        assert(array.count == 2)
        assert(array[0].objMnemonic == "EXPEXUS")
        
        let obj = try genObject!.findAssociationOne(haveType: AscMetaType.IMPLBY)
        //print(obj!.objMnemonic)
        assert(obj!.objMnemonic == "IMPLGIC")
    }
    
    func testMeta() {
        let genContainer = JGenContainer()
        _ = genContainer.connect(to: containerPath)
        let meta = genContainer.meta

        assert(meta?.getDefaultCharProperty(hasObjType: ObjMetaType.ACBLKBSD, hasPrpType: PrpMetaType.CONIND) == "N")

        assert(meta?.getDefaultTextProperty(hasObjType: ObjMetaType.ACBLKBSD, hasPrpType: PrpMetaType.DESC) == "")

        assert(meta?.getDefaultNumberProperty(hasObjType: ObjMetaType.ACBLKBSD, hasPrpType: PrpMetaType.CEID) == 0)
   
        assert(meta!.getAssociationCodes(hasObjType: ObjMetaType.ACBLKBSD).count == 61)
        
        assert(meta!.getPropertyCodes(hasObjType: ObjMetaType.ACBLKBSD).count == 46)

        assert(meta!.isAssociationOnetoOne(hasObjType: ObjMetaType.ACBLKBSD, hasAscType: AscMetaType.SPWNDFM) == true)
        
        assert(meta!.isAssociationOnetoOne(hasObjType: ObjMetaType.ACBLKBSD, hasAscType: AscMetaType.ISINVKED) == false)
        
        assert(meta!.isAssociationForward(hasObjType: ObjMetaType.ACBLKBSD, hasAscType: AscMetaType.DEFINES) == false)
        
        assert(meta!.isAssociationOptional(hasObjType: ObjMetaType.ACBLKBSD, hasAscType: AscMetaType.HASART) == true)
        
        assert(meta!.isAssociationOrdered(hasObjType: ObjMetaType.ACBLKBSD, hasAscType: AscMetaType.DEFINES) == false)
    }
 
    static var allTests = [
        ("testContainer", testContainer),
        ("testModel", testModel),
        ("testObject", testObject),
         ("testMeta", testMeta),
        ("testSampleApplication", testSampleApplication),
    ]
}
