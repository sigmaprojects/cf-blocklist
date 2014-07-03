component {

	public any function init(required downloadService, required listService) {
		variables.downloadService = arguments.downloadService;
		variables.listService = arguments.listService;
		variables.cacheName = "listcache";
		variables.scheduleUrl = 'https://blocklist.sigmaprojects.org/?reindex=true&requestTimeout=1200';
		variables.interval = 43200; // in seconds: 43200 seconds is 12 hour
		verifyScheduler();
	}
	
	public void function index() {
		var list = variables.listService.list();
		list.each( function(list) {
			populate(list);
		}, true ); // multi-thread this shiz
	}
	
	public void function populate(required list) {
		var down = variables.downloadService.download( arguments.list );
		
		var dirtyArray = ListToArray(down, chr(10) );
		var cleanArray = ArrayNew(1);
		
		for(var item in dirtyArray) {
			var range = listLast(item,':');
			if( ListLen(range,'-') EQ 2 and trim(len(range)) GT 5 and ReFind('[A-Za-z]',range) EQ 0) {
				ArrayAppend(cleanArray,trim(range));
			}
		}
		
		arguments.list.setList( cleanArray );
		arguments.list.setUpdated( Now() );
		arguments.list.setEntries( ArrayLen(cleanArray) );
		variables.listService.save( arguments.list );

		cacheList(list);

		createFile(arguments.list);
	}

	public binary function gzip(required string data, string format='binary') {
		//http://www.cflib.org/udf/gzip
		var result="";
		var text=createObject("java","java.lang.String").init(arguments.data);
		var dataStream=createObject("java","java.io.ByteArrayOutputStream").init();
		var compressDataStream=createObject("java","java.util.zip.GZIPOutputStream").init(dataStream);
		compressDataStream.write(text.getBytes());
		compressDataStream.finish();
		compressDataStream.close();

		if(arguments.format neq 'binary'){
			result=binaryEncode(dataStream.toByteArray(),arguments.format);
		}else{
			result=dataStream.toByteArray();
		}
		return result;
	}
	
	public any function getListCache(Required String Title) {
		if( listCacheExists(arguments.Title) ) {
			return cacheGet(
				key			= trim(arguments.Title),
				cacheName	= variables.cacheName
			); 
		} else {
			populate( variables.listService.get(title) );
		}
		return cacheGet(
			key			= trim(arguments.Title),
			cacheName	= variables.cacheName
		); 
	}
	
	public boolean function listCacheExists(Required String Title) {
		return cachekeyexists( key=trim(arguments.Title), cacheName=variables.cacheName );
	}
	
	private void function cacheList(Required list) {
		cachePut(
			key			= list.getTitle(),
			value		= list.getList(),
			cacheName	= variables.cacheName
		);
	}


	private void function createFile(required list) {
		var string = ArrayToList(arguments.list.getList(),chr(10));
		
		var binary = gzip(string);

		try {
			FileDelete(application.outputPath & arguments.list.getTitle() & '.gz');
		} catch(Any e) {}
		FileWrite(application.outputPath & arguments.list.getTitle() & '.gz', binary);
	}


	private void function verifyScheduler() {
		schedule action="update" startDate="#Now()#" startTime="00:00:01" interval="#variables.interval#" url="#variables.scheduleUrl#" task="Reindex_Lists" requesttimeout="1200";
	}

	
}