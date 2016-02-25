<!---	quick and dirty example
		if the url term key exists (which comes from jquery autocomplete by default)
		run whats in the cfif block, filter the query using querytoarrayofstructures for simplicity
		and because client may not have "keep original case" turned on in the Railo admin, lower case everything.
		exit out and return the json results
--->
<cfscript>
/**
 * http://www.cflib.org/udf/querytoarrayofstructures
 * Converts a query object into an array of structures.
 * 
 * @param query      The query to be transformed 
 * @return This function returns a structure. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1, September 27, 2001 
 */
function QueryToArrayOfStructures(theQuery){
    var theArray = arraynew(1);
    var cols = ListtoArray(theQuery.columnlist);
    var row = 1;
    var thisRow = "";
    var col = 1;
    for(row = 1; row LTE theQuery.recordcount; row = row + 1){
        thisRow = structnew();
        for(col = 1; col LTE arraylen(cols); col = col + 1){
            thisRow[cols[col]] = theQuery[cols[col]][row];
        }
        arrayAppend(theArray,duplicate(thisRow));
    }
    return(theArray);
}
</cfscript>
<cfif structKeyExists(url,'term')>
	<cfset dbase = query(
		id		:[1,2,3,4,5,6],
		emp_name:["George","John","Thomas","James","Andrew","Martin"],
		active	:[true,true,true,true,true,false]
	) />
	<cfquery name="results" dbtype="query">
		SELECT
			emp_name as label,
			id
		FROM dbase
		WHERE active = true
		AND emp_name LIKE <cfqueryparam value="%#url.term#%" cfsqltype="cf_sql_varchar" />
	</cfquery>
	<cfset resultsArray = QueryToArrayOfStructures(results) />
	<cfset resultsJson = lCase( serializeJson(resultsArray) ) />
	<cfset WriteOutput( resultsJson ) />
	<cfabort>
</cfif>

<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>jQuery UI Autocomplete - Multiple, remote</title>
	<link rel="stylesheet" href="//code.jquery.com/ui/1.11.2/themes/smoothness/jquery-ui.css">
	<script src="//code.jquery.com/jquery-1.10.2.js"></script>
	<script src="//code.jquery.com/ui/1.11.2/jquery-ui.js"></script>
	<link rel="stylesheet" href="/resources/demos/style.css">
	<style>
		.ui-autocomplete-loading {
			background: white url("images/ui-anim_basic_16x16.gif") right center no-repeat;
	}
	</style>
	<script>
		$(function() {
			function log( message ) {
				$( "<div>" ).text( message ).prependTo( "#log" );
				$( "#log" ).scrollTop( 0 );
			}
 
			$( "#employees" ).autocomplete({
				source: "autocompleteexample.cfm",
				minLength: 2,
				select: function( event, ui ) {
					log( ui.item ?
					"Selected: " + ui.item.value + " aka " + ui.item.id :
					"Nothing selected, input was " + this.value );
				}
			});
		});
	</script>
</head>
<body>
	<div class="ui-widget">
		<label for="employees">Employees: </label>
		<input id="employees" size="50">
	</div>
	<div class="ui-widget" style="margin-top:2em; font-family:Arial">
		Result:
		<div id="log" style="height: 200px; width: 300px; overflow: auto;" class="ui-widget-content"></div>
	</div>
</body>
</html>