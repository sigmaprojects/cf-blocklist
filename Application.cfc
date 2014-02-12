<cfcomponent output="false" hint="Sets up the application and defines top level event handlers.">

	<cfscript>
		THIS.Name = "Blocklist";
		THIS.ApplicationTimeout = CreateTimeSpan( 200, 0, 0, 0 );
		
		THIS.Mappings[ "/Blocklist" ] = ExpandPath('./');
		THIS.Mappings[ "/model" ] = ExpandPath('./model/');
		THIS.datasource='blocklistprovider';
		THIS.ormenabled = true;
		THIS.ormsettings = {
			dialect="MySQLwithMyISAM",
			dbcreate="update",
			cfclocation="/model"
		};
	</cfscript>

	

	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false" hint="Fires when application starts.">
		<cfset application.apiCache = {} />
		<cfset application.listCache = {} />
		<cfset application.tmpPath = expandPath('/tmp/') />
		<cfset application.outputPath = ExpandPath('/output/') />
		<cfset application.RangeToCidr = CreateObject("java", "RangeToCidr", "/javalib/RangeToCidr.jar") />
		<cfset application.authService = new model.authService() />
		<cfset application.listService = new model.listService() />
		<cfset application.zipService = new model.zipService() /> 
		<cfset application.downloadService = new model.downloadService(application.zipService) />
		<cfset application.maintainService = new model.maintainService(application.downloadService,application.listService) />
		<cfset application.reqService = new model.reqService() /> 
		<cfset application.api = new api() />  
		<cfreturn true />
	</cffunction>

	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="true" hint="Fires when a request starts.">
		<cfargument name="Page" type="string" required="true" hint="The user-requested template." />
		<cfif structKeyExists(url,'fwreinit')>
			<cfset OnApplicationStart() />
		</cfif>
		<cfif structKeyExists(url,'reindex')>
			<cfset application.maintainService.index() />
		</cfif>
		<cfif structKeyExists(url,'ormreload')>
			<cfset ORMReload() />
		</cfif>
		<cfreturn true />
	</cffunction>


	<cffunction name="onRequestEnd" access="public" returntype="void" output="false" hint="Fires when request ends.">
		<cfargument name="Page" type="string" required="true" hint="The user-requested template." />
		<cfif structKeyExists(url,'fwreinit')>
			<cfset ApplicationStop() />
			<cfset THIS.ApplicationTimeout = CreateTimeSpan( 0, 0, 0, 0 ) />
		</cfif>
		<cfreturn />
	</cffunction>

	<cffunction name="OnSessionStart" access="public" returntype="void" output="false" hint="Fires when session starts.">
		<cfreturn />
	</cffunction>

	<cffunction name="onSessionEnd" returnType="void" hint="Fires when session ends.">
		<cfargument name="SessionScope" required="true" />
		<cfargument name="ApplicationScope" required="true" />
	</cffunction>

<!---
	<cffunction name="onMissingTemplate" returnType="boolean" output="false">
		<cfargument name="thePage" type="string" required="true">
		<cflocation url="/home" statuscode="301" addtoken="no" />
		<cfreturn true />
	</cffunction>
--->

<!---
	<cffunction name="OnError" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch.">
		<cfargument name="Exception" type="any" required="true" hint="The exception object thrown by the application."/>
		<cfargument name="EventName" type="string" required="false" default="" hint="The name of the exception."/>
		<cfset var errorDump = '' />
		<cfreturn />
	</cffunction>
--->


	<!--- props to Ben --->
	<cffunction name="onCFCRequest" access="public" returntype="void" output="true" hint="I process the user's CFC request.">
		<cfargument name="component" type="string" required="true" hint="I am the component requested by the user."/>
		<cfargument name="methodName" type="string" required="true" hint="I am the method requested by the user."/>
		<cfargument name="methodArguments" type="struct" required="true" hint="I am the argument collection sent by the user."/>

		<cfif !structKeyExists(application.apiCache, arguments.component)>
			<cfset application.apiCache[arguments.component] = createObject("component", arguments.component).init()/>
		</cfif>

		<cfset local.cfc = application.apiCache[arguments.component]/>

		<cfset local['result'] = '' />
		<cfinvoke returnvariable="local.result" component="#local.cfc#" method="#arguments.methodName#" argumentcollection="#arguments.methodArguments#"/>

		<cfset local['responseData'] = ""/>
		<cfset local['responseMimeType'] = "text/plain"/>
		<cfif !StructKeyExists(url,'returnFormat')>
			<cfset url.returnFormat = 'binary' />
			<cfset local.responseExtension = 'gz' />
		<cfelse>
			<cfparam name="url.returnFormat" type="string" default="#getMetaData( local.cfc[ arguments.methodName ] ).returnFormat#"/>
			<cfset local.responseExtension = 'json' />
		</cfif>

		<cfif structKeyExists(local, "result")>
			<cfif ((url.returnFormat eq "json") && !structKeyExists(url, "callback"))>
				<cfset local.responseData = serializeJSON(local.result)/>
				<cfset local.responseMimeType = "text/x-json"/>
			<cfelseif ((url.returnFormat eq "json") && structKeyExists(url, "callback"))>
				<cfset local.responseData = ("#url.callback#(" & serializeJSON(local.result) & ");")/>
				<cfset local.responseMimeType = "text/javascript"/>
			<cfelseif (url.returnFormat eq "wddx")>
				<cfwddx action="cfml2wddx" input="#local.result#" output="local.responseData"/>
				<cfset local.responseMimeType = "text/xml"/>
			
			<cfelseif (url.returnFormat eq "binary")>
				
				<cfset local.responseMimeType = "application/x-gzip" />
				<cfset local.responseData = local.result />
				
			<cfelse>
				<cfset local.responseData = local.result />
				<cfset local.responseMimeType = "text/plain"/>
			</cfif>
		</cfif>
	
		<!---
		    Now that we have our response data and mime type variables defined, we can stream the response back to the client.
		    Convert the response to binary.
		--->
		<cfset local.binaryResponse = toBinary(toBase64(local.responseData))/>
		<!---
		    Set the content length (to help the client know how much data is coming back).
		--->
		<cfif structKeyExists(request,'reqID')>
			<cfset var req = application.reqService.get( Request.ReqID ) />
			<cfset req.setByteSize( arrayLen(local.binaryResponse) ) />
			<cfset application.reqService.save(req) />
		</cfif>
		
		<cfheader name="content-disposition" value="attachment; filename=return.#local.responseExtension#" />
		<cfheader name="content-length" value="#arrayLen( local.binaryResponse )#"/>

		<cfcontent type="#local.responseMimeType#" variable="#local.binaryResponse#"/>

		<cfreturn/>
	</cffunction>


</cfcomponent>