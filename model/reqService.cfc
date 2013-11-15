component {

	public void function save(required req) {
		if( IsNull(arguments.req.getCreated()) OR !IsDate(arguments.req.getCreated()) ) {
			arguments.req.setCreated(Now());
		}
		if( IsNull(arguments.req.getByteSize()) OR !IsNumeric(arguments.req.getByteSize()) ) {
			arguments.req.setByteSize(0);
		}
		EntitySave(arguments.req);
	}
	
	public any function get(required reqid) {
		return EntityLoad('req', arguments.reqid, true);
	}

	public array function list(filter={},sort='',options={}) {
		return EntityLoad('req', arguments.filter, arguments.sort, arguments.options); 
	}

	public void function delete(required req) {
		EntityDelete(arguments.req);
	}

	public string function getTotalByteSize() {
		var bytesize = new Query(datasource='blocklistprovider',sql="SELECT SUM(bytesize) as totalbytes FROM requests").execute().getResult();
		return byteAutoConvert(bytesize.totalbytes);
	}

	public any function getFirst() {
		var first = list(sort='created DESC');
		return first[1];
	}
	
	public any function byteAutoConvert(required numeric bytes, numeric maxreduction=9) {
		var units = listToArray("B,KB,MB,GB,TB,PB,EB,ZB,YB",","); 
		var conv = 0;
		var exp = 0;
    
		if( arguments.maxreduction gte 9 ) {
			arguments.maxreduction = arraylen(units) - 1;
		}
    
		if( arguments.bytes gt 0) {
			exp = fix(log(arguments.bytes) / log(1024));
			if(exp gt arguments.maxreduction) {
				exp = arguments.maxreduction;
        	}
			conv = arguments.bytes / (1024^exp);
		}
            
		return "#trim(lsnumberformat(conv,"_____.00"))# #units[exp + 1]#";
	}
	

}