component table="requests" persistent="true" {


	property name="reqid"		type="numeric"	ormtype="int"   	notnull="true"	fieldtype="id"	generator="native";
	property name="ipaddr"		type="string"  	ormtype="string"	length="16"		notnull="true";
	property name="lists"		type="string"  	ormtype="string"	length="500"	notnull="true";
	property name="bytesize"	type="numeric"	ormtype="int"   	length="255"	notnull="true";
	property name="created"		type="date"		ormtype="timestamp"					notnull="true";

}
