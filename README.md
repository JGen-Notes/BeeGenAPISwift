# Bee Gen API for Swift


[![N|Solid](jgernnotes200x45.png)](http://www.jgen.eu/?p=900&preview=true)

Overview
========

Bee Gen API for Java is part of a more significant project Bee Gen Model Framework. The framework allows extracting design metadata from the CA Gen Local model and import to the framework. The framework has its method of storing metadata in a dedicated sort of container and preset it as a model. Bee Gen API provides a means to access such metadata, constituting what we consider a model imported from the CA Gen.

A container uses SQLite as a means of storing and retrieving information. Therefore you need to have SQLite installed in your environment. Since SQLite and Java are portable and can run on many supporting platforms, the framework and applications developed using the framework can be installed and run on all those supporting platforms.

[Bee Gen API for Java doumentation can be downloded here.](https://github.com/JGen-Notes/BeeGenAPIJava/blob/master/eu.jgen.beegen.model.api/BeeGenAPIDoc.zip)

More about project you can find [here](http://www.jgen.eu/?p=900&preview=true).

> The Bee Gen Model Framework is still under
> development and subject to changes.
> 

Versions of used Software
=========================

- [SQLite Release 3.33.0 On 2020-08-14](https://sqlite.org/index.html)

- [sqlite-jdbc-3.32.3.2](https://github.com/xerial/sqlite-jdbc/releases)

- [Java SE 8 1.8.0_05](https://www.oracle.com/java/technologies/javase-jre8-downloads.html)

- [Eclipse Version: 2020-06 (4.16.0)](https://www.eclipse.org/downloads/)

Example of use
==============

Here is an example of the Java program using the API.

```sh
package eu.jgen.beegen.model.api.example;

import eu.jgen.beegen.model.api.JGenContainer;
import eu.jgen.beegen.model.api.JGenModel;
import eu.jgen.beegen.model.api.JGenObject;
import eu.jgen.beegen.model.meta.ObjMetaType;
import eu.jgen.beegen.model.meta.PrpMetaType;

public class ListAllActionBlockNames {

	public static void main(String[] args) {
		JGenContainer genContainer = new JGenContainer();
		JGenModel genModel = genContainer.connect("/Users/Xxxxx/beegen01.ief/bee/BEEGEN01.db");
		System.out.println("List of action blocks in the model: " + genModel.getName() + ", Using schema level: "
				+ genModel.getSchema() + "\n");
		for (JGenObject genObject : genModel.findTypeObjects(ObjMetaType.ACBLKBSD)) {
			System.out.println("\tAction block name: " + genObject.findTextProperty(PrpMetaType.NAME) + ", having id: "
					+ genObject.objId);
		}
		genContainer.disconnect();
		System.out.println("\nCompleted.");
	}

}
```

It produces the following output:

```sh
List of action blocks in the model: BEEGEN01, Using schema level: 9.2.A6

	Action block name: PERSON_CREATE, having id: 22020096
	Action block name: PERSON_DELETE, having id: 22020097
	Action block name: PERSON_UPDATE, having id: 22020098
	Action block name: PERSON_READ, having id: 22020099
	Action block name: PERSON_LIST, having id: 22020100

Completed.
```
