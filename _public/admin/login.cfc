<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("Security")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = Super.loadData()>
	
	<cfset vars.SiteName = "">
	
	<cfif Variables.Security.isLoggedIn()>
		<cfset go("index.cfm")>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>