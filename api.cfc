component output=false {

	public api function init() {
		variables.listService = application.listService;
		variables.maintainService = application.maintainService;
		variables.downloadService = application.downloadService;
		variables.authService = application.authService;
		variables.reqService = application.reqService;
		variables.RangeToCidr = application.RangeToCidr;
		return This;
	}

	remote array function forceUpdate(required string lists) returnFormat="json" output=false {
		var requestArray = listToArray(arguments.lists);
		var resultArray = [];

		if(!variables.authService.exists(arguments.apiKey)) {
			ArrayAppend(resultArray,{error=true,msg='Invalid API Key.'});
			return resultArray;
		}
		
		for(var title in requestArray) {
			if(IsNull(EntityLoadByPk('list', title))) {
				ArrayAppend(resultArray,{error=true,msg='list #title# does not exist.'});
			} else {
				variables.maintainService.populate( variables.listService.get(title) );
				ArrayAppend(resultArray,{error=false,msg='list #title# has been updated.'});
			}
		}
		
		return resultArray;
	}

	remote struct function addList(
		required	string		Url,
		required	string		Title,
		required	string		Description,
					boolean		Public		=	false,
		required	string		apiKey
	) returnFormat="json" output=false {
		if(!variables.authService.exists(arguments.apiKey)) {
			return {error=true,msg='Invalid API Key.'};
		}
		if(variables.listService.titleExists(arguments.title)) {
			return {error=true,msg='List Title already exists.'};
		}
		var list = new model.list();
			list.setUrl(trim( arguments.Url ));
			list.setTitle(trim( arguments.Title ));
			list.setDescription(trim( arguments.Description ));
			list.setPublic(trim( arguments.Public ));
		variables.listService.save(list);
		return {error=false,msg='List has been added.'};
	}
	
	remote any function getList(required string lists, boolean CIDR=true) output=false returnformat="plain" {
		var requestArray = listToArray(arguments.lists);
		var stringListArray = ArrayNew(1);
		if(arguments.lists == '*') {
			requestArray = variables.listService.getAllIDs();
		}
		
		
		for(var title in requestArray) {
			var tmplist = application.maintainService.getListCache(title);
			stringListArray.addAll(tmplist);
		}


		if( arguments.CIDR ) {
			for( var i=1; i lte arrayLen(stringListArray); i++ ) {
				if( isSimpleValue(stringListArray[i]) && ListLen(stringListArray[i],'-') eq 2 ) {
					var IP1 = listFirst(stringListArray[i],'-');
					var IP2 = listLast(stringListArray[i],'-');
					try {
						var ipCIDR = variables.RangeToCidr.range2cidrlist(IP1,IP2);
						stringListArray[i] = ipCIDR;
					} catch(any e) {
						i--;
						arrayDeleteAt(stringListArray,i);
					}
				} else {
					i--;
					arrayDeleteAt(stringListArray,i);
				}
			}
		}
		
		var stringList = stringListArray.toString();
			// random fix string stuff 
			stringList = ReplaceNoCase(stringList,'[','','all');
			stringList = ReplaceNoCase(stringList,']','','all');
			stringList = ReplaceNoCase(stringList,',',chr(10),'all');
			stringList = ReplaceNoCase(stringList,' ','','all');

		var binary = variables.maintainService.gzip( stringList );
		
		var req = new model.req();
			req.setLists(arguments.lists);
			req.setIpaddr(cgi.REMOTE_ADDR);
			req.setuseragent(cgi.http_user_agent);
			req.setCreated(Now());
			variables.reqService.save(req);
			//ugly hack to apease application.cfc
			request.reqid = req.getReqID();
			
		return binary;
	}

	remote struct function getRequests(
		Numeric		Rows		= 50,
		Numeric		Page		= 1,
		String		sidx		= 'created',	// the column to sort by
		String		sord		= 'desc'		// the sort direction
	) returnFormat="json" output=false {
		var requests = application.reqService.search(argumentCollection=arguments);
		return requests;
		//return serializeJson(requests);
	}




}