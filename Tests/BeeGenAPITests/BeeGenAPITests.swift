import XCTest
import SQLite
@testable import BeeGenAPI

final class BeeGenAPITests: XCTestCase {
    func testExample() {
        
        do {
           
            print("\ntest follow many:\n")
            let connection = try Connection("/Users/marek/beegen/model01/db/model01.db")
            let model = GenModel(connection: connection)
            //
           
            for fromObject in try model.fetchObjects(haveType: ObjTypeCode.HLENT.rawValue) {
                print("\(fromObject.id)  \(fromObject.name)")
                for toObject in try fromObject.followAssociationMany(haveType: AscTypeCode.DSCBYA.rawValue) {
                    print("\t\(toObject.name)")
                }
            }
            
            //
            print("\ntest follow one:\n")
            for fromObject in try model.fetchObjects(haveType: ObjTypeCode.ACBLKBSD.rawValue) {
                print("\(fromObject.id)  \(fromObject.name)")
                guard let toObject = try fromObject.followAssociationOne(haveType: AscTypeCode.GRPBY.rawValue) else {
                    print("Cannot find any association of that type.")
                    return
                }
                   print("\t\(toObject.id)  \(toObject.name)")

            }
            
            
            
        } catch  {
            print(error)
        }
        
        
        

    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
