<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("SessionMgr")>
<cfset loadExternalVars("Users",".Security",true,1)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = Super.loadData()>
	
	<cfset param("URL.permission","numeric",0)>
	
	<cfreturn vars>
</cffunction>

<cffunction name="getUsers" access="public" returntype="query" output="no">
	
	<cfset var qCurrUser = variables.Users.getUser(UserID=variables.SessionMgr.getValue("AdminID"),fieldlist="UserID,isUniversal")>
	<cfset var qUsers = 0>
	
	<!--- Only universal user can see universal users --->
	<cfif NOT ( qCurrUser.isUniversal EQ true )>
		<cfset arguments["isUniversal"] = false>
	</cfif>
	
	<cfif URL.permission>
		<cfset arguments["Permissions"] = URL.permission>
	</cfif>
	
	<cfset qUsers = variables.Users.getUsers(argumentCollection=arguments)>
	
	<!--- User should not be able to delete themselves --->
	<cfif ListFindNoCase(qUsers.ColumnList,"isDeletable")>
		<cfloop query="qUsers">
			<cfif UserID EQ qCurrUser.UserID>
				<cfset QuerySetCell(qUsers,"isDeletable",false,CurrentRow)>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn qUsers>
</cffunction>

</cfcomponent>