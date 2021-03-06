# Bee Gen API for Swift


[![N|Solid](jgernnotes200x45.png)](http://www.jgen.eu/?p=900&preview=true)

Overview
========

Bee Gen API for Swift is part of the Bee Gen Model Framework project. The framework allows extracting design metadata from the CA Gen Local model and import design data to the framework. The framework has its own method of storing metadata in a dedicated container and present its contents as a model. Bee Gen API provides a means to access such metadata, constituting what we consider a model imported from the CA Gen.

A container uses SQLite as a means of storing and retrieving information. Therefore you need to have SQLite installed in your environment. Since SQLite and partly Swift are portable and can run on few supporting platforms, the framework and applications developed using the framework can be installed and run on all those supporting platforms.

Bee Gen API for Swift doumentation is not extracted from the source codet yet and will be provided in near future.

More about project you can find [here](http://www.jgen.eu/?p=900&preview=true).

> The Bee Gen Model Framework is still under
> development and subject to changes.
> 

Versions of used Software
=========================

- [SQLite Release 3.33.0 On 2020-08-14](https://sqlite.org/index.html)

- [SQLite.swift](https://github.com/stephencelis/SQLite.swift)

- [Swift 5.3](https://swift.org)

- [XCode 12](https://developer.apple.com/xcode/)

Example of use
==============

Here is an sample of the Swift code using the API.

```sh
   func testSampleApplication() {
        let containerPath = "/Users/Xxxxx/beegen01.ief/bee/BEEGEN01.db"
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
```

It produces the following output:

```sh
List of action blocks in the model: BEEGEN01, Using schema level: BEEGEN01

	Action block name: PERSON_CREATE, having id: 22020096
	Action block name: PERSON_DELETE, having id: 22020097
	Action block name: PERSON_UPDATE, having id: 22020098
	Action block name: PERSON_READ, having id: 22020099
	Action block name: PERSON_LIST, having id: 22020100

Completed.
```
