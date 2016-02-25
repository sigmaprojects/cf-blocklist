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
	
	public numeric function count() {
		var countQuery = new Query(datasource='blocklistprovider',sql="SELECT COUNT(1) as totalcount FROM requests").execute().getResult();
		return countQuery.totalcount;
	}
	
	/*
rows:20
page:1
sidx:lists
sord:asc
searchField:ipaddr
searchString:127.0.0.1
searchOper:cn
eq	equal
ne	not equal
lt	less
le	less or equal
gt	greater
ge	greater or equal
in	is in
ni	is not in	
cn	contains
nc	does not contain
*/
	
	public struct function search(
		Numeric		Rows			= 50,
		Numeric		Page			= 1,
		String		sidx			= 'created',	// the column to sort by
		String		sord			= 'desc',		// the sort direction
		String		searchField		= '',
		String		searchString	= '',
		String		searchOper		= ''
	) {
		if( !Len(trim(arguments.sidx)) ) {
			arguments.sidx = 'created';
		}
		var offset = (arguments.Page-1)*arguments.rows;
		var results = {};
		var requests = [];
		
		var searchOperArray = ['eq','ne','lt','le','gt','ge','in','ni','cn','nc'];
		var searchFieldArray = ['reqid','ipaddr','lists','bytesize','created','useragent'];
		var sordArray = ['asc','desc'];
		
		if(
			Len(trim(arguments.searchString)) &&
			arrayContains(searchOperArray,arguments.searchOper) &&
			arrayContains(searchFieldArray,arguments.searchField) && 
			cgi.remote_addr contains '192.168.1.'
		) {
			
			var str = trim(arguments.searchString);
			switch(arguments.searchOper) {
				case 'eq': { var op = '='; break; }
				case 'ne': { var op = '!='; break; }
				case 'lt': { var op = '<'; break; }
				case 'le': { var op = '<='; break; }
				case 'gt': { var op = '>'; break; }
				case 'ge': { var op = '>='; break; }
				case 'cn': { var op = 'LIKE'; str = '%' & str & '%'; break; }
				case 'nc': { var op = 'NOT LIKE'; str = '%' & str & '%'; break; }
			}
			if( !arguments.searchField contains 'reqid' ) {
				str = "'" & str & "'";
			}
			
			requests = ORMExecuteQuery("FROM req WHERE #arguments.searchField# #op# #str# ORDER BY #arguments.sidx# #arguments.sord#", false, {offset=offset, maxresults=arguments.rows, timeout=50});
			
		} else if( arrayContains(searchFieldArray,arguments.sidx) && arrayContains(sordArray,arguments.sord) ) {
			requests = ORMExecuteQuery("FROM req ORDER BY #arguments.sidx# #arguments.sord#", false, {offset=offset, maxresults=arguments.rows, timeout=50});
		} else {
			requests = ORMExecuteQuery("FROM req", false, {offset=offset, maxresults=arguments.rows, timeout=50});
		}
		
		
		var rows = [];
		for(var req in requests) {
			arrayAppend(rows,req.toJSON());
		}
		results['rows'] = rows;
		results['page'] = arguments.page;
		results['total'] = ormExecuteQuery("select count(id) from req", true);//arguments.rows;
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