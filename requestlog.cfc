component {
	
	public any function init() {
		return this;
	}
	
	remote any function getRequests(Struct Args={}) returnformat="plain" {
		var requests = application.reqService.search( argumentCollection=url );
		return serializeJson(requests);
	}
	
}