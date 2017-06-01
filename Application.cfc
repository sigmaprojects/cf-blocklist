component output="false" hint="Sets up the application and defines top level event handlers." {

	THIS.Name = "Blocklist-16";
	THIS.ApplicationTimeout = CreateTimeSpan( 30, 0, 0, 1 );
	
	THIS.Mappings[ "/Blocklist" ] = ExpandPath('./');
	THIS.Mappings[ "/model" ] = ExpandPath('./model/');
	this.datasources["blocklistprovider"] = {
		  class: 'org.gjt.mm.mysql.Driver'
		, connectionString: 'jdbc:mysql://192.168.1.75:3306/blocklistprovider?useUnicode=true&characterEncoding=UTF-8&tinyInt1isBit=true&autoReconnect=true&jdbcCompliantTruncation=true&useOldAliasMetadataBehavior=true&allowMultiQueries=false&useLegacyDatetimeCode=true'
		, username: 'blocklist'
		, password: "encrypted:2c2efe7d083b7edf5050bd0ffbe656e86202640cd045db71f1f788190fcb0b53a8b3be7fdbffc8d53b8e23727070c0ca"
		
		// optional settings
		, blob:true // default: false
		, clob:true // default: false
	};
	THIS.datasource='blocklistprovider';
	THIS.ormenabled = true;
	THIS.ormsettings = {
		dialect="MySQLwithMyISAM",
		dbcreate="update",
		cfclocation="/model"
	};

	
	public boolean function OnApplicationStart() {
		application.dsn = THIS.datasource;
		application.apiCache = {};
		application.listCache = {};
		application.tmpPath = expandPath('./tmp/');
		application.outputPath = ExpandPath('./output/');
		application.RangeToCidr = CreateObject("java", "RangeToCidr", "/javalib/RangeToCidr.jar");
		application.authService = new model.authService();
		application.listService = new model.listService();
		application.zipService = new model.zipService();
		application.downloadService = new model.downloadService(application.zipService);
		application.maintainService = new model.maintainService(application.downloadService,application.listService);
		application.reqService = new model.reqService(); 
		application.api = new api();
		return true;
	}

	
	public boolean function OnRequestStart(Required String Page) {
		if( structKeyExists(url,'fwreinit') ) {
			OnApplicationStart();
		}
		if( structKeyExists(url,'reindex') ) {
			application.maintainService.index();
		}
		if( structKeyExists(url,'ormreload') ) {
			ORMReload();
		}
		return true;
	} 

	
	public void function onRequestEnd(Required String Page) {
		if( structKeyExists(url,'fwreinit') ) {
			ApplicationStop();
			THIS.ApplicationTimeout = CreateTimeSpan( 0, 0, 0, 0 );
		}
	}

	
	//public void function OnSessionStart() {}


	//public void function onSessionEnd(Required Struct SessionScope, Required Struct ApplicationScope) {}


	//public boolean function onMissingTemplate(Required String Page) {}
	
	
	//public void function onError(Required Any Exception, String EventName="") {}


	public void function onCFCRequest(
		Required String cfc,
		Required String methodName,
		Required Struct methodArguments
	) {

		if( !structKeyExists(application.apiCache, arguments.cfc) && !arguments.cfc contains "requestlog" ) {
			application.apiCache[arguments.cfc] = createObject("component", arguments.cfc).init();
		}

		if( arguments.cfc contains "requestlog" ) {
			local.cfc = createObject("component", arguments.cfc).init();
		} else {
			local.cfc = application.apiCache[arguments.cfc];
		}

		local['result'] = '';
		
		//invoke returnvariable="local.result" component=local.cfc method=arguments.methodName argumentcollection=arguments.methodArguments {}
		local.result = invoke(local.cfc,arguments.methodName,arguments.methodArguments); 
		//local.result = local.cfc[arguments.methodName]();

		local['responseData'] = "";
		local['responseMimeType'] = "text/plain";
		if( !StructKeyExists(url,'returnFormat') ) {
			url.returnFormat = 'binary';
			local.responseExtension = 'gz';
		} else {
			param name="url.returnFormat" type="string" default="#getMetaData( local.cfc[ arguments.methodName ] ).returnFormat#";
			local.responseExtension = 'json';
		}

		if( structKeyExists(local, "result") ) {
			if( ((url.returnFormat eq "json") && !structKeyExists(url, "callback")) ) {
				local.responseData = serializeJSON(local.result);
				//local.responseMimeType = "text/x-json";
				local.responseMimeType = "application/json";
			} else if( url.returnFormat eq "json" && structKeyExists(url, "callback") ) {
				local.responseData = ("#url.callback#(" & serializeJSON(local.result) & ");");
				local.responseMimeType = "text/javascript";
			} else if( url.returnFormat eq "wddx" ) {
				wddx action="cfml2wddx" input="#local.result#" output="local.responseData";
				local.responseMimeType = "text/xml";
			} else if( url.returnFormat eq "binary" ) { 
				local.responseMimeType = "application/x-gzip";
				local.responseData = local.result;
			} else {
				local.responseData = local.result;
				local.responseMimeType = "text/plain";
			}
		}
	
		/*
		    Now that we have our response data and mime type variables defined, we can stream the response back to the client.
		    Convert the response to binary.
		*/
		local.binaryResponse = toBinary(toBase64(local.responseData));
		/*
		    Set the content length (to help the client know how much data is coming back).
		*/
		if( structKeyExists(request,'reqID') ) {
			var req = application.reqService.get( Request.ReqID );
			req.setByteSize( arrayLen(local.binaryResponse) );
			application.reqService.save(req);
		}

		header name="content-disposition" value="attachment; filename=return.#local.responseExtension#";
		header name="content-length" value="#arrayLen( local.binaryResponse )#";

		content type="#local.responseMimeType#;charset=utf-8" variable="#local.binaryResponse#";
		return;
	}
}

