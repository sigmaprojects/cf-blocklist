component table="list" persistent="true" {


	property name="title"		type="string"	ormtype="string"	length="30"		notnull="true"	fieldtype="id"	generator="assigned";
	property name="url"			type="string"  	ormtype="string"	length="500"	notnull="true";
	property name="description"	type="string"	ormtype="string"	length="2000";
	property name="updated"		type="date"		ormtype="timestamp"					notnull="true";
	property name="entries"		type="numeric"	ormtype="integer"					notnull="true";
	property name="public"		type="numeric"	ormtype="integer"	length="1"		notnull="true";

	property name="list"		type="array"	persistent="false" ;


	public array function getList() {
		if(IsNull(variables.list) or !IsArray(variables.list)) {
			return ArrayNew(1);
		}
		return variables.list;
	}


}
