component {

	public any function init(required downloadService, required listService) {
		variables.downloadService = arguments.downloadService;
		variables.listService = arguments.listService;
	}
	
	public void function index() {
		var list = variables.listService.list();
		for(var item in list) {
			populate(item);
		}
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

		updateApplicationListCache(list);

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
	
	private void function updateApplicationListCache(required list) {
		lock scope="application" type="exclusive" timeout="30" throwontimeout="false" {
			application.listCache[ arguments.list.getTitle() ] = arguments.list;
		}
	}


	private void function createFile(required list) {
		var string = ArrayToList(arguments.list.getList(),chr(10));
		
		var binary = gzip(string);

		try {
			FileDelete(application.outputPath & arguments.list.getTitle() & '.gz');
		} catch(Any e) {}
		FileWrite(application.outputPath & arguments.list.getTitle() & '.gz', binary);
	}


	
}