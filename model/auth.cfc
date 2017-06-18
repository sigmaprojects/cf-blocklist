component table="auth" persistent="true" accessors="true"  {

	property name="username"	type="string"	fieldtype="id"		ormtype="string"	notnull="true"	length="30"	generator="assigned";
	property name="password"	type="string"	fieldtype="id"		ormtype="string"	notnull="true"	length="60"	generator="assigned";
	property name="apiKey"		type="string"	ormtype="string"   	notnull="true"		length="35";
		
	
}
