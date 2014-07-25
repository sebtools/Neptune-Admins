<cfcomponent output="false" security_permissions="Users">

<cffunction name="config" access="public" returntype="void" output="no">
	<cfif
			StructKeyExists(Application,"Security")
		AND	StructKeyExists(Application.Security,"checkBasicPageAccess")
	>
		<cfset Application.Security.checkBasicPageAccess(CGI.SCRIPT_NAME)>
	</cfif>
</cffunction>

<cffunction name="config_BAK" access="public" returntype="void" output="no">
	<cfargument name="Config" type="any" required="yes">
	
	<cfset Config.paramSetting("SessionScope","Session")>
	<cfset Config.paramSetting("SessionTimeout",90)>
	<cfset Config.paramSetting("SecurityLoginPage","/admin/login.cfm")>
	<cfset Config.paramSetting("SecurityLogoutPage","/admin/logout.cfm")>
	<cfset Config.paramSetting("SecuritySuccessPage","/admin/index.cfm")>
	<cfset Config.paramSetting("SecurityAccessVars","AdminID")>
	
	<cfparam name="Session.AdminID" default="0">
	
	<!--- Check security for admin section --->
	<cfif Left(CGI.SCRIPT_NAME,7) EQ "/admin/" AND StructKeyExists(Application,"Security") AND StructKeyExists(Application,"Users")>
		<cfset IgnorePages = "#Config.getSetting('SecurityLoginPage')#,#Config.getSetting('SecurityLogoutPage')#,/admin/users/user-edit.cfm">
		<cfset qUsers = Application.Users.getUsers()>
		<cfif qUsers.RecordCount>
			<!--- Check access or perform log-in --->
			<cfinvoke component="#Application.Security#" method="checkAccess">
				<cfinvokeargument name="LoginPage" value="#Config.getSetting('SecurityLoginPage')#">
				<cfinvokeargument name="SuccessPage" value="#Config.getSetting('SecuritySuccessPage')#">
				<cfinvokeargument name="AccessVars" value="#Config.getSetting('SecurityAccessVars')#">
				<cfinvokeargument name="TimeOut" value="#Config.getSetting('SessionTimeout')#">
			</cfinvoke>
		<cfelseif NOT ListFindNoCase(IgnorePages,CGI.SCRIPT_NAME)>
			<cflocation url="/admin/users/user-edit.cfm" addtoken="no">
		</cfif>
		
		<!--- Force user to edit admin/admin record if one exists --->
		<cfif
				StructKeyExists(Application.Users,"getMustChangeAdminID")
			AND	NOT ListFindNoCase(IgnorePages,CGI.SCRIPT_NAME)
		>
			<cfset changeadminid = Application.Users.getMustChangeAdminID()>
			<cfif changeadminid AND NOT StructCount(Form)>
				<cflocation url="/admin/users/admin-edit.cfm?id=#changeadminid#" addtoken="no">
			</cfif>
		</cfif>
	</cfif>
	
</cffunction>

<cffunction name="components" access="public" output="yes">
<program name="Admins" description="I manage the site administrators." permissions="Users">
	<components>
		<component name="SessionMgr" path="com.sebtools.SessionMgr">
			<argument name="scope" arg="SessionScope" ifmissing="skiparg" />
		</component>
		<component name="Security" path="[path_component]model.Security">
			<argument name="Manager" />
			<argument name="SessionMgr" />
		</component>
	</components>
</program>
</cffunction>

</cfcomponent>