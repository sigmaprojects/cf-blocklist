<cfcomponent>
	<cffunction name="init" access="public" returntype="zipService">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="unzip" access="public" output="false" returntype="String">
		<cfargument name="infile" type="string" required="true" />
		<cfargument name="outfile" type="string" default="#CreateUUID()#.txt" />
		
		<cfzip file="#application.tmpPath & arguments.infile#" action="list" name="entry">
		<cfset var original_file = entry.name />
		
		<cfzip file="#application.tmpPath & arguments.infile#" action="unzip" destination="#application.tmpPath#"/> 
		 
		<cffile action="rename" source="#application.tmpPath & original_file#" destination="#application.tmpPath & arguments.outfile#" attributes="normal">
		<cfset var fileContents = FileRead( application.tmpPath & arguments.outfile ) />
		<cfset FileDelete( application.tmpPath & arguments.outfile ) />
		<cfset FileDelete( application.tmpPath & arguments.infile ) />
		<cfreturn fileContents />
	</cffunction>

</cfcomponent>