<!---
<cfoutput>
	<cfset lists = application.listService.list() />

	<cfloop array="#lists#" index="list">
		<p>
			Title: #list.getTitle()# <br />
			URL: #list.getURL()# <br />
			Description: #list.getDescription()# <br />
		</p>
	</cfloop>

	<form method="post" action="action.cfm?action=addlist">

		Title: <input type="text" name="title" id="title" />
		<br />
		URL: <input type="text" name="url" id="url" />
		<br />
		Description: <br />
		<textarea name="description" id="description"></textarea>
		<br />
		<input type="submit" />

	</form>

</cfoutput>
--->