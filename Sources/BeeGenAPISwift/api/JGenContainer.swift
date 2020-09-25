//
//  JGenContainer.swift
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
import HeliumLogger
import LoggerAPI

///
///
/// This object represents a container.
///
/// Bee Gen Model Framework uses the SQLite database to store metadata representing
/// your application design as imported from the CA Gen Local Model. The container
/// connects to the specific location of the SQLite database and provides access
/// to the model. Therefore container represents the SQLite database as its specific physical implementation.
///
/// - Author: Marek Stankiewicz
///
///  - Since: 1.0.0
///
public class JGenContainer {
    
    public var containerLocation: String = ""
    
    public init() {
    }
    
    ///
    /// Connects to the SQLite database storing metadata with the application design.
    ///
    /// - Parameters:
    ///     - containerPath:  path to the SQLite database file
    /// - Returns: Object representing model or `nil` if connection was unsuccessful.
    ///
    public func connect(to containerLocation: String) throws -> JGenModel {
        self.containerLocation = containerLocation
        do {
            let logger = HeliumLogger()
            Log.logger = logger
            let connection = try Connection(containerLocation )
            let genModel = try JGenModel(containedin: self, connection: connection).retriveModelInfo()
       //     self.meta = MetaHelper(genContainer: self)
            Log.info("Connected to the model: \(String(describing: genModel.getName())).")
            return genModel
        } catch {
            Log.error("Cannot connect to SQLite database")
            throw JGenException.someProblemConnectingSQLite(description: "Cannot connect to SQLite database")
         }
    }
    
    ///
    /// Returns path to the location of the SQLite database as used during connect operation.
    ///
    /// - Returns: Path to the location of SQLite database
    public func getContainerLocation() -> String {
       return containerLocation
    }
    
}
