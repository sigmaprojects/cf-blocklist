<cfabort>
<cfswitch expression="#url.action#">
	<cfcase value="addlist">
		<cfif structKeyExists(form,'title') and structKeyExists(form,'url') and structKeyExists(form,'description') and len(form.title) GT 0 and len(form.url) gt 0>
			<cfset list = new model.list() />
			<cfset list.setUrl(form.url) />
			<cfset list.setTitle(LCase(form.title)) />
			<cfset list.setDescription(form.description) />
			<cfset Application.listService.save(list) />
		</cfif>
		<cflocation url="lists.cfm" addtoken="false" />
	</cfcase>
	<cfdefaultcase>
		
	</cfdefaultcase>
</cfswitch>