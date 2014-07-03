<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		<title>
			Blocklist.SigmaProjects.org
		</title>
		<meta http-equiv="Expires" content="0"/>
		<link rel="stylesheet" type="text/css" href="style/default.css" media="screen"/>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js" type="text/javascript"></script>
		<script type="text/javascript">
			$(document).ready(function(){
				$("#addlist-form").submit(function(){
					$.post(
						"api.cfc?method=addlist&returnFormat=json",
						$("#addlist-form").serialize(),
						function(data){
							 $('#reponse').append(data.MSG + '<br />');
							 if(!data.ERROR) {
							 	$("#addlist-form")[0].reset();
								$('#reponse').append('<br /> Refresh the page to see it in the list.');
							 }
						}
					);
					return false;
				});
			});
		</script>
		<script type="text/javascript">
			var _gaq = _gaq || [];
			_gaq.push(['_setAccount', 'UA-3393421-12']);
			_gaq.push(['_setDomainName', 'blocklist.sigmaprojects.org']);
			_gaq.push(['_trackPageview']);

  		(function() {
			var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
			ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
			var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
		})();
	</script>
	</head>
	<body>
		<div id="wrapper">
			<div id="main">
				<div id="nav">
				</div>
				<div id="header">
					<h1>
						<a href="https://blocklist.sigmaprojects.org">
							IP Blocklist
						</a>
						<blockquote>
							<cfoutput>
							List requests served to date: #ArrayLen(application.reqService.list())#
							&nbsp; &nbsp; 
							Totalling #application.reqService.getTotalByteSize()#
							</cfoutput> 
						</blockquote>
					</h1>
				</div>
				<div id="content">
					<div class="top">
					</div>
					<div class="sides">
						<blockquote>
							<p>
								Simple stuff, IP Block Lists.  A Collection of established and constantly updated range of
								IP addresses.  Parsed for our purposes and mirrored here.
							</p>
							<p>
								You <i>can</i> use this as well.  Feel free to use the below links, or ask our api to 
								combine selected lists into a single download.
								<a href="https://blocklist.sigmaprojects.org/api.cfc?method=getlist&lists=drop,zeus,spyware">https://blocklist.sigmaprojects.org/api.cfc?method=getlist&lists=drop,zeus,spyware</a>
								Would give you a combined drop, zues, and spyware list, change as you see fit.
								If you need the returned lists to be in a range format, instead of the default CIDR, you can pass the URL paramter "&CIDR=false".  
								Be aware, if I consider your requests as abusive, you'll be blocked.  So keep it down to twice a day.
								<p>
									<a href="https://github.com/sigmaprojects/cf-blocklist" target="_blank">Source</a> - Just a lil scary.
								</p>
								
							</p>
						</blockquote>

						<h2>
							The lists
						</h2>
						<ul>
							<cfset lists = application.listService.list({public=true}) />
							<cfoutput>
							<cfloop array="#lists#" index="list">
								<p>
								<li>
									<a href="/api.cfc?method=getList&lists=#list.getTitle()#">#list.getTitle()#</a>
									&nbsp; - &nbsp; #list.getDescription()#
									<ul>
										<li>
											Source: <strong>#GetToken(list.getURL(),2,'/')#</strong>
										</li>
										<li>
											Records: <strong>#list.getEntries()#</strong>
										</li>
										<li>
											Updated: <strong>#DateFormat(list.getUpdated())# #TimeFormat(list.getUpdated(),'long')#</strong>
										</li>
									</ul>
								</li>
								</p>
							</cfloop>
							</cfoutput>
						</ul>
						<p>
							&nbsp;
						</p>

						<p>
							<div class="top"></div>
							<div class="sides">
								<form id="addlist-form" name="form" method="post">
									<h3>Add a list</h3>
									<p>Want to add a list?  <a href="https://www.sigmaprojects.org/contact/" target="_blank">Contact us</a> for an Api Key</p>

									<label>Title <span class="small">The name/title of the list</span></label>
									<input type="text" name="title" id="title" />

									<label>URL <span class="small">Valid URL to the list</span></label>
									<input type="text" name="url" id="url" />

									<label>Description <span class="small">A brief description of the list</span></label>
									<textarea name="description" id="description"></textarea>

									<label>Api Key <span class="small">A valid api key.</span></label>
									<input type="text" name="apikey" id="apikey" />

									<label>Public <span class="small">Public (listed here) or not?</span></label>
									<input type="checkbox" name="public" value="true" checked="checked" />

									<button type="submit">Submit</button>
									<div class="spacer"></div>
									<blockquote id="reponse"></blockquote>
								</form>
							</div>
							<div class="bottom"></div>
						</p>

						<p>
							&nbsp;
						</p>

					</div>
					<div class="bottom">
					</div>
				</div>
				<div id="footer">
					<p>
						<a href="https://www.sigmaprojects.org">
							&copy; Sigma Projects
						</a>
						&nbsp; (Designed by:<a href="http://www.asimpletemplate.com" target="_blank">aSimpleTemplate.com</a>)
					</p>
				</div>
			</div>
			<div id="r_column">
			</div>
		</div>
	</body>
</html>



<!---
<cfoutput>
	<cfset lists = application.listService.list() />

	<cfloop array="#lists#" index="list">
		<p>
			Title: #list.getTitle()# <br />
			Source: #list.getURL()# <br />
			Local: <a href="/output/#list.getTitle()#.gz">/output/#list.getTitle()#.gz</a> <br />
			Description: #list.getDescription()# <br />
		</p>
	</cfloop>

</cfoutput>
--->