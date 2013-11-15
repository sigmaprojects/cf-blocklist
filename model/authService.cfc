component {


	public any function validate(
			required	string	UserName,
			required	string	Password
		) output=false {
		var CompositeKey = {
			UserName	= Trim(Arguments.UserName),
			Password	= Hash(Trim(Arguments.Password))
		};
		return EntityLoadByPK('auth',CompositeKey);
	}
	
	public boolean function exists(required string apiKey) {
		var lookup = EntityLoad('auth', {apiKey=arguments.apiKey});
		if(ArrayLen(lookup)) {
			return true;
		}
		return false;
	}
	

	private auth function create(
			required	string	UserName,
			required	string	Password
		) output=false {
		local.auth = New model.auth();
		local.auth.setUserName( Trim(Arguments.username) );
		local.auth.setPassword( Hash(Trim(Arguments.Password)) );
		local.auth.setAPIKey( CreateUUID() );
		EntitySave(local.auth);
		return local.auth;
	}


}