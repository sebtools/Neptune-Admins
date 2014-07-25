<cfcomponent displayname="Security: Users" extends="com.sebtools.RecordsTester" output="no">

<cffunction name="setUp" access="public" returntype="void" output="no">
	
	<cfset loadExternalVars("Users",".Security")>
	
</cffunction>

<cffunction name="shouldUserBeApprovedByDefault" access="public" output="no"
	hint="A new user should be approved by default.">
	
	<cfset var sUser = Variables.Users.validateUser(UserID=0)>
	
	<cfif NOT ( StructKeyExists(sUser,"DateApproved") AND isDate(sUser.DateApproved) )>
		<cfset fail("The user was not approved.")>
	</cfif>
	
</cffunction>

<cffunction name="shouldUserNameBeUnique" access="public" output="no"
	mxunit:expectedException="Security"
	hint="A user should be unique.">
	
	<cfset var qUsers = Variables.Users.getUsers(MaxRows=1,fieldlist="username")>
	<cfset var sUser = Variables.Users.validateUser(UserID=0,username=qUsers.username)>
	
</cffunction>

</cfcomponent>