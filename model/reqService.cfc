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
	
	/*
rows:20
page:1
sidx:lists
sord:asc
$responce->page = $page; $responce->total = $total_pages; $responce->records = $count;
	*/
	
	public struct function search(
		Numeric		Rows		= 50,
		Numeric		Page		= 1,
		String		sidx		= 'created',	// the column to sort by
		String		sord		= 'desc'		// the sort direction
	) {
		if( !Len(trim(arguments.sidx)) ) {
			arguments.sidx = 'created';
		}
		var offset = (arguments.Page-1)*arguments.rows;
		var results = StructNew();
		var requests = ORMExecuteQuery("FROM req ORDER BY #arguments.sidx# #arguments.sord#", false, {offset=offset, maxresults=arguments.rows, timeout=50});
		var rows = [];
		for(var req in requests) {
			arrayAppend(rows,req.toJSON());
		}
		results['rows'] = rows;
		
		results['page'] = arguments.page;
		results['total'] = ormExecuteQuery("select count(id) from req", true)/arguments.rows;
		results['records'] = arrayLen(rows);
		
		return results;
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