component table="requests" persistent="true" accessors="true"  {


	property name="reqid"		type="numeric"	ormtype="int"   	notnull="true"	fieldtype="id"	generator="native";
	property name="ipaddr"		type="string"  	ormtype="string"	length="16"		notnull="true";
	property name="useragent"	type="string"  	ormtype="string"	length="500"	notnull="true";
	property name="lists"		type="string"  	ormtype="string"	length="500"	notnull="true";
	property name="bytesize"	type="numeric"	ormtype="int"   	length="255"	notnull="true";
	property name="created"		type="date"		ormtype="timestamp"					notnull="true";


	public any function getSizeConvert() {
		var maxreduction=9;
		var bytes = getbytesize();
		var units = listToArray("B,KB,MB,GB,TB,PB,EB,ZB,YB",","); 
		var conv = 0;
		var exp = 0;
    
		if( maxreduction gte 9 ) {
			maxreduction = arraylen(units) - 1;
		}
    
		if( bytes gt 0) {
			exp = fix(log(bytes) / log(1024));
			if(exp gt maxreduction) {
				exp = maxreduction;
        	}
			conv = bytes / (1024^exp);
		}
            
		return "#trim(lsnumberformat(conv,"_____.00"))# #units[exp + 1]#";
	}
	
	public struct function toJSON() {
		var data = {};
		data['reqid']		= getreqid();
		data['ipaddr']		= getipaddr();
		data['useragent']	= HTMLEditFormat(getuseragent());
		data['lists']		= HTMLEditFormat(getlists());
		data['bytesize']	= getbytesize();
		data['sizeconvert']	= getSizeConvert();
		data['created']		= getcreated();
		data['date']		= dateFormat(getCreated(),'medium') & ' ' & timeFormat(getcreated(),'medium');
		return data;
	}

}
