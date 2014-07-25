<cfcomponent displayname="Security UI" extends="com.sebtools.SeleniumTester">

<cffunction name="setUp" access="public" returntype="void" output="no">
	
	<cfset super.setup()>
	<cfset loadExternalVars("Security,SessionMgr")>
	
</cffunction>

<cffunction name="login" access="public" returntype="void" output="no" hint="I log a user in." test="false">
				
	<cfset var qAdmin = Variables.Security.Users.getUsers(isUniversal=true,fieldlist="UserID,username,password",MaxRows=1)>
	
	<cfif NOT qAdmin.RecordCount>
		<cfset qAdmin = Variables.Security.Users.getUsers(fieldlist="UserID,username,password,isUniversal",MaxRows=1)>
		<!---<cfdump var="#qSuperAdmin#">
		<cfabort>
		<cfthrow message="A universal admin must exist for Security UI tests to work.">--->
	</cfif>
	
	<cfscript>
	variables.Selenium.open("/admin/");
	variables.Selenium.type("username", qAdmin.Username);
	variables.Selenium.type("password", qAdmin.Password);
	variables.Selenium.click("//input[@value='Submit']");
	variables.Selenium.waitForPageToLoad("30000");
	</cfscript>
	
</cffunction>

<!--- Selenium Tests --->

<cffunction name="shouldLoginWork" access="public" returntype="void" output="no" 
			hint="The login form should log in valid users.">
	
	<cfset var sSession = 0>
	
	<cfset login()>
	<cfset sSession = getSessionScope()>
	
	<cfif NOT ( StructKeyExists(sSession,"AdminID") AND Val(sSession.AdminID) )>
		<cfset fail("Failed to login.")>
	</cfif>
	
</cffunction>

</cfcomponent>