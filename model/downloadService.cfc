component {

	public any function init(required zipService) {
		variables.zipService = arguments.zipService;
	}

	public any function download(required list) {

		var httpService = new http();
			httpService.setUserAgent('Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; T312461; .NET CLR 1.1.4322)');
			httpService.setMethod("get");
			httpService.setFile( arguments.list.getTitle() & '.zip' );
			httpService.setPath( application.tmpPath );
			httpService.setUrl( arguments.list.getURL() );
			httpService.send().getPrefix();
		var txtstring = variables.zipService.unzip( arguments.list.getTitle() & '.zip' );
		return txtstring;
	}


}