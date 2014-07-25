<cfcomponent extends="com.sebtools.Records" output="no">

<cffunction name="addPermissions" access="public" returntype="void" output="false" hint="I add permissions to a user.">
	<cfargument name="UserID" type="numeric" required="true">
	<cfargument name="Permissions" type="string" required="true">
	
	<cfset var qUser = getUser(UserID=Arguments.UserID,fieldlist="UserID,Permissions")>
	<cfset var sArgs = StructNew()>
	
	<cfset sArgs.UserID = Arguments.UserID>
	<cfset sArgs.Permissions = ListAppend(qUser.Permissions,Arguments.Permissions)>
	
	<cfset saveUser(ArgumentCollection=sArgs)>
	
</cffunction>

<cffunction name="approveUser" access="public" returntype="void" output="no">
	<cfargument name="UserID" type="numeric" required="true">
	
	<cfset saveRecord(UserID=Arguments.UserID,DateApproved=now())>
	
</cffunction>

<cffunction name="getMustChangeAdminID" access="public" returntype="numeric" output="false" hint="I get the ID of the admin that must be changed (zero if no such admin).">
	
	<cfset var result = 0>
	<cfset var qUsers = getUsers(username="admin",password="admin",fieldlist="UserID")>
	
	<cfif qUsers.RecordCount AND variables.DataMgr.getDatabase() NEQ "Sim">
		<cfset result = qUsers.UserID>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="validateUser" access="public" returntype="struct" output="no">
	
	<cfset Arguments = validateDateApproved(ArgumentCollection=Arguments)>
	<cfset Arguments = validateUsername(ArgumentCollection=Arguments)>
	
	<cfreturn Arguments>
</cffunction>

<cffunction name="validateDateApproved" access="private" returntype="struct" output="no">
	
	<cfset var oUser = RecordObject(Record=Arguments)>
	<cfset var sArgs = Duplicate(Arguments)>
	
	<cfif oUser.isNewRecord()>
		<cfif NOT StructKeyExists(Arguments,"DateApproved")>
			<cfset Arguments.DateApproved = now()>
		</cfif>
	<cfelse>
		<cfset StructDelete(sArgs,"DateApproved")>
		<cfset oUser = RecordObject(Record=sArgs,fields="DateApproved")>
		<cfif isDate(oUser.get("DateApproved"))>
			<cfset StructDelete(Arguments,"DateApproved")>
		</cfif>
	</cfif>
	
	<cfreturn Arguments>
</cffunction>

<cffunction name="validateUsername" access="private" returntype="struct" output="no">
	<cfreturn Arguments>
</cffunction>

</cfcomponent>