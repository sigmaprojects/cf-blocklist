<cfif structKeyExists(url,'getRequests')>
<cfset requests = application.reqService.search( argumentCollection=url ) />
<cfcontent type="application/json; charset=utf-8" variable="#toBinary( toBase64( serializeJson(requests) ) )#"/><cfabort>
<!---
<cfcontent type="application/json;charset=utf-8" variable="#toBinary( toBase64( serializeJson(requests) ) )#"/>
--->
</cfif>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>Blocklist Request Log</title>

<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/themes/smoothness/jquery-ui.css" />
<!---
<link rel="stylesheet" type="text/css" media="screen" href="/jqGrid/css/ui-lightness/jquery-ui-1.7.1.custom.css" />
--->
<link rel="stylesheet" type="text/css" media="screen" href="/jqGrid/css/ui.jqgrid.css" />


<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
 
<script src="/jqGrid/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="/jqGrid/js/jquery.jqGrid.min.js" type="text/javascript"></script>
 
</head>
<body>
<cfoutput>#cgi.REMOTE_ADDR#</cfoutput>
<cfdump var='#cgi#' />


<table id="list2"></table>
<div id="pager2"></div>


</body>

<script type="text/javascript">
jQuery("#list2").jqGrid({
	//datatype: "local",
	//url:'/api.cfc?method=getRequests',
	url:'/requestlog.cfc?getRequests=true&method=getRequests&returnFormat=plain',
	datatype: "json",
	height: $(document).height()-120,
	width: $(document).width()-120,
   	colNames:['ID','IP','U-Agent','Lists', 'Size','Date'],
   	colModel:[
   		{name:'reqid',index:'reqid', width:'5%', sorttype:"int"},
   		
		{name:'ipaddr',index:'ipaddr', width:'10%'},
		
		{name:'useragent',index:'useragent', width:'20%'},
		
		{name:'lists',index:'lists', width:'30%'},
		
		{name:'sizeconvert',index:'bytesize', width:'7%'},
		
		{name:'date',index:'created', width:'10%', sorttype:"date"}
   	],
	rowNum:50,
	sortname: 'created',
	sortorder: 'desc',
   	//multiselect: true,
   	caption: "Blocklist Request Log",
	pager: '#pager2',
}).navGrid("#pager2",{edit:false,add:false,del:false});;


//jQuery("#list2").jqGrid('navGrid','#pager2',{edit:false,add:false,del:false});

/*
var mydata = [
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"},
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"},
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"},
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"},
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"},
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"},
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"},
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"},
		{id:"1",ipaddr:"127.0.0.1",lists:"test,test,test,",sizeconvert:"54.1 mb",created:"asdasd"}
		
		];
for (var i = 0; i <= mydata.length; i++) {
	jQuery("#list2").jqGrid('addRowData', i + 1, mydata[i]);
}
*/
</script>

</html>


<!---
<cfoutput>
<table>
	<tr>
		<th>ID</th>
		<th>IP</th>
		<th>Lists</th>
		<th>Size</th>
		<th>Date</th>
	</tr>
	<cfloop array="#application.reqService.list(sort='created desc')#" index="req">
		<tr>
			<td>#req.getreqid()#</td>
			<td>#req.getipaddr()#</td>
			<td>#req.getlists()#</td>
			<td>#req.getSizeConvert()#</td>
			<td>#DateFormat(req.getCreated(),'medium')# #TimeFormat(req.getCreated(),'medium')#</td>
		</tr>
	</cfloop>
</table>
</cfoutput>
--->