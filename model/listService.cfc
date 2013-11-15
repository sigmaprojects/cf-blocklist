component {

	public void function save(required list) {
		if( IsNull(arguments.list.getEntries()) OR !IsNumeric(arguments.list.getEntries()) ) {
			arguments.list.setEntries(0);
		}
		if( IsNull(arguments.list.getUpdated()) OR !IsDate(arguments.list.getUpdated()) ) {
			arguments.list.setUpdated(Now());
		}
		if( IsNull(arguments.list.getPublic()) OR !IsBoolean(arguments.list.getPublic()) ) {
			arguments.list.setPublic( true );
		}
		arguments.list.setTitle( LCase(Trim(arguments.list.getTitle())) );
		arguments.list.setUrl( Trim(arguments.list.getUrl()) );
		EntitySave(arguments.list);
	}
	
	public Array function getAllIDs() {
		var lists = list();
		var idsArray = arrayNew(1);
		for(var item in lists) {
			arrayAppend(idsArray,item.getTitle());
		}
		return idsArray;
	}
	
	public any function get(required listid) {
		return EntityLoadByPk('list', arguments.listid);
	}
	
	public array function list(filter={},sort='',options={}) {
		return EntityLoad('list', arguments.filter, arguments.sort, arguments.options); 
	}
	
	public void function delete(required list) {
		EntityDelete(arguments.list);
	}

	public boolean function titleExists(required string title) {
		var lookup = list(filter=arguments);
		if(ArrayLen(lookup)) {
			return true;
		}
		return false;
	}

}