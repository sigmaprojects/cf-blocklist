component {

	public any function init(required zipService) {
		variables.zipService = arguments.zipService;
	}

	public any function download(required list) {
		/*
		var httpService = new http();
			httpService.setUserAgent('Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; T312461; .NET CLR 1.1.4322)');
			httpService.setMethod("get");
			httpService.setFile( arguments.list.getTitle() & '.zip' );
			httpService.setPath( application.tmpPath );
			httpService.setUrl( arguments.list.getURL() );
			httpService.send().getPrefix();
		*/
		var destination = application.tmpPath & '/' & arguments.list.getTitle() & '.zip' ;
		var uri = createObject("java", "java.net.URL").init( arguments.list.getURL() );
		var uis = uri.openStream();
		var bis = createObject("java", "java.io.BufferedInputStream").init(uis);
		var fos = createObject("java", "java.io.FileOutputStream").init(destination);
		var bos = createObject("java", "java.io.BufferedOutputStream").init(fos);
		var buffer = getByteArray(1024);
		var len = bis.read(buffer);
		while(len > 0) {
			bos.write(buffer,0,len);
			len = bis.read(buffer);
		}
		bos.close();
		bis.close();
		fos.close();
		uis.close();
		
		var txtstring = variables.zipService.unzip( arguments.list.getTitle() & '.zip' );
		return txtstring;
	}

	public binary function getByteArray(Required Numeric Size) {
		var emptyByteArray = createObject("java", "java.io.ByteArrayOutputStream").init().toByteArray();
		var byteClass = emptyByteArray.getClass().getComponentType();
		var byteArray = createObject("java","java.lang.reflect.Array").newInstance(byteClass, arguments.size);
		return byteArray;
	}
	

}