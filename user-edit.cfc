<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("SessionMgr")>
<cfset loadExternalVars("Users,Permissions",".Security",true,1)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = Super.loadData()>
	
	<cfset vars.Alert = "">
	<cfif NOT variables.Users.hasUsers()>
		<cfset vars.Alert = "You must create an administrator account.">
	<cfelseif variables.Users.getMustChangeAdminID()>
		<cfset vars.Alert = "You must change the default administrator account.">
	</cfif>
	<cfset vars.hasPermissionsPermission = variables.Security.checkUserAllowed("Permissions")>
	<cfset vars.isUserUniversal = ( variables.SessionMgr.exists("isUniversal") AND variables.SessionMgr.getValue("isUniversal") IS true )>
	
	<cfif vars.hasPermissionsPermission>
		<cfset vars.qPermissions = variables.Permissions.getPermissions()>
		<cfset vars.sebFields["Permissions"] = StructFromArgs(
			type="checkbox",
			subquery="qPermissions",
			subvalues="PermissionID",
			subdisplays="PermissionName"
		)>
	<cfelseif Application.SessionMgr.exists("Permissions")>
		<cfset vars.sebFields["Permissions"] = StructFromArgs(type="hidden",defaultValue=variables.SessionMgr.getValue("Permissions"))>
	</cfif>
	
	<cfif vars.isUserUniversal>
		<cfset vars.TemplateAttributes = StructNew()>
		<cfset vars.TemplateAttributes.files_js = "/lib/jquery/jquery.js,user-edit.js">
	</cfif>
	
	<cfreturn vars>
</cffunction>

<cffunction name="saveUser" access="public" returntype="numeric" output="false" hint="I save the admin user. If this is the first user, I also log-in the current user as that administrator.">
	
	<cfset var hasUsers = variables.Users.hasUsers()>
	<cfset var result = variables.Users.saveUser(argumentCollection=arguments)>
	<cfset var qUser = 0>
	
	<cfif NOT hasUsers>
		<cfset qUser = variables.Users.getUser(UserID=result,fieldlist="username,password")>
		<cfset variables.Security.checkLogin(username=qUser.username,password=qUser.password)>
	</cfif>
	
	<cfreturn result>
</cffunction>

</cfcomponent>