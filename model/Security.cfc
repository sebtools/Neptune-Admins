<cfcomponent displayname="Security" extends="com.sebtools.ProgramManager">

<cfset variables.prefix = "sec">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="Manager" type="any" required="yes">
	<cfargument name="SessionMgr" type="any" required="yes">
	
	<cfset initInternal(argumentcollection=arguments)>
	
	<cfset Variables.SecureRoot = getSecureRoot()>
	
	<cfset Variables.Manager.Security_Register(This)>
	
	<cfset upgrade()>
	
	<cfreturn This>
</cffunction>

<cffunction name="addPermissions" access="public" returntype="void" output="no">
	<cfargument name="Permissions" type="string" required="yes">
	
	<cfset var PermissionList = Variables.Permissions.getPermissionIDs()>
	<cfset var permission = "">
	<cfset var permissionid = 0>
	<cfset var NewPermissionIDs = "">
	<cfset var NewPermissionNames = "">
	
	<cfloop list="#Arguments.Permissions#" index="permission">
		<cfif Len(Trim(permission))>
			<cfset permissionid = Variables.Permissions.savePermission(PermissionName=permission)>
			<!--- Any user responsible for adding a permission should get that permission --->
			<cfif NOT ListFindNoCase(PermissionList,permissionid)>
				<cfset NewPermissionIDs = ListAppend(NewPermissionIDs,permissionid)>
				<cfset NewPermissionNames = ListAppend(NewPermissionNames,permission)>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--- Any user responsible for adding a permission should get that permission --->
	<cfif ListLen(NewPermissionIDs)>
		<cfif variables.SessionMgr.exists("AdminID")>
			<cfset Variables.Users.addPermissions(variables.SessionMgr.getValue("AdminID"),NewPermissionIDs)>
		</cfif>
		<cfif variables.SessionMgr.exists("Permissions")>
			<cfset variables.SessionMgr.setValue("Permissions",ListAppend(variables.SessionMgr.getValue("Permissions"),NewPermissionIDs))>
		</cfif>
		<cfif variables.SessionMgr.exists("PermissionNames")>
			<cfset variables.SessionMgr.setValue("PermissionNames",ListAppend(variables.SessionMgr.getValue("PermissionNames"),NewPermissionNames))>
		</cfif>
	</cfif>
	
</cffunction>

<cffunction name="checkBasicPageAccess" access="public" returntype="void" output="no" hint="I check to see if the current has the appropriate access.">
	<cfargument name="ScriptName" type="string" required="true">
	
	<cfset var CurrUserID = 0>
	<cfset var MustChangeID = 0>
	<cfset var redir = "">
	
	<cfif isSecuredPath(Arguments.ScriptName)>
		<cfif NOT isLoggedIn()>
			<cfset redir = getNoAccessURL(Arguments.ScriptName)>
		<cfelse>
			<cfset CurrUserID = Variables.SessionMgr.getValue("AdminID")>
			<cfset MustChangeID = Variables.Users.getMustChangeAdminID()>
			<cfif CurrUserID GT 0 AND CurrUserID EQ MustChangeID>
				<cfset redir = "#getSecureRoot()#admins/user-edit.cfm?id=#MustChangeID#">
			</cfif>
		</cfif>
		
		<cfif Len(redir) AND ListFirst(redir,"?") NEQ Arguments.ScriptName>
			<cflocation url="#redir#" addtoken="false">
		</cfif>
	</cfif>
	
</cffunction>

<cffunction name="checkAccess_BAK" access="public" returntype="void" output="no" hint="I check to see if the current has the appropriate access.">
	<cfargument name="LoginPage" type="string" required="yes" hint="The URL (CGI.SCRIPT_NAME format) of the log in form.">
	<cfargument name="SuccessPage" type="string" required="yes" hint="The URL (CGI.SCRIPT_NAME format) to which the user should be sent upon successful log in.">
	<cfargument name="AccessVars" type="string" default="AdminID" hint="A comma-delimited list of session variables that can be non-zero to allow access.">
	<cfargument name="TimeOut" type="numeric" default="90" hint="The time limit (in minutes) between page views for log in expiration.">
	<cfargument name="usernamefield" type="string" required="no" hint="If provided, the form field to check for the user's username.">
	<cfargument name="passwordfield" type="string" required="no" hint="If provided, the form field to check for the user's password.">
	<cfargument name="AllowedPages" type="string" default="" hint="A comma-delimited of URLs (CGI.SCRIPT_NAME format) that are allowed for users that are not logged in.">
	<cfargument name="currPage" type="string" default="#CGI.SCRIPT_NAME#" hint="The URL (CGI.SCRIPT_NAME format) of the current page.">
	<cfargument name="username" type="string" required="no" hint="The user's username.">
	<cfargument name="password" type="string" required="no" hint="The user's password.">
	<cfargument name="ShowWhyFail" type="boolean" default="false" hint="Should we tell why the login failed (username or password)?">
	
	<!--- This method uses form variables, but only by name given and it checks for existence. --->
	
	<cfset var isLoggedIn = false>
	<cfset var AccessVar = "">
	
	<cfif
			StructKeyExists(arguments,"usernamefield")
		AND	NOT StructKeyExists(arguments,"username")
		AND	StructKeyExists(Form,arguments.usernamefield)
	>
		<cfset arguments.username = Form[arguments.usernamefield]>
	</cfif>
	<cfif
			StructKeyExists(arguments,"passwordfield")
		AND	NOT StructKeyExists(arguments,"password")
		AND	StructKeyExists(Form,arguments.passwordfield)
	>
		<cfset arguments.password = Form[arguments.passwordfield]>
	</cfif>
	
	<cfloop index="AccessVar" list="#arguments.AccessVars#">
		<cfif variables.SessionMgr.exists(AccessVar) AND variables.SessionMgr.getValue(AccessVar) NEQ 0>
			<cfset isLoggedIn = true>
			<cfif NOT isCurrent(arguments.TimeOut)>
				<cfset isLoggedIn = false>
				<cfset logout()>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfif NOT isLoggedIn>
		<cfif StructKeyExists(arguments,"username") AND	StructKeyExists(arguments,"password")>
			<cftry>
				<cfset checkLogin(arguments.username,arguments.password,arguments.ShowWhyFail)>
				<cflocation url="#arguments.SuccessPage#" addtoken="No">
				<cfcatch>
					<cflocation url="#arguments.LoginPage#?err=#CFCATCH.message#" addtoken="No">
				</cfcatch>
			</cftry>
		<cfelseif currPage NEQ arguments.LoginPage AND NOT ListFindNoCase(AllowedPages, currPage)>
			<cflocation url="#arguments.LoginPage#" addtoken="No">
		</cfif>
	<cfelseif currPage EQ arguments.LoginPage>
		<cflocation url="#arguments.SuccessPage#" addtoken="No">
	</cfif>
	
</cffunction>

<cffunction name="checkLogin" access="public" returntype="void" output="no" hint="I check the given login.">
	<cfargument name="username" type="string" required="yes">
	<cfargument name="password" type="string" required="yes">
	<cfargument name="ShowWhyFail" type="boolean" default="false" hint="Should we tell why the login failed (username or password)?">

	<cfset var errMessage = "">
	<cfset var qLogin = 0>
	<cfset var fields = "UserID,FirstName,LastName,FullName,isUniversal,Permissions,PermissionNames">
	<cfset var LoginTime = now()>
	
	<!--- Logout --->
	<cfset logout()>
	
	<cfif NOT ( Len(arguments.username) AND Len(arguments.password) )>
		<cfthrow message="username and password are required" type="LoginErr" errorcode="LoginErr">
	</cfif>
	
	<!--- Check for admin --->
	<cfset qLogin = variables.Users.getUsers(username=arguments.username,password=arguments.password,fieldlist=fields,isApproved=true)>
	
	<!--- If user is admin --->
	<cfif qLogin.RecordCount>
		<cfset variables.SessionMgr.setValue("AdminID",qLogin.UserID)>
		<cfset variables.SessionMgr.setValue("FirstName",qLogin.FirstName)>
		<cfset variables.SessionMgr.setValue("LastName",qLogin.LastName)>
		<cfset variables.SessionMgr.setValue("FullName",qLogin.FullName)>
		<cfset variables.SessionMgr.setValue("isUniversal",qLogin.isUniversal)>
		<cfset variables.SessionMgr.setValue("Permissions",qLogin.Permissions)>
		<cfset variables.SessionMgr.setValue("PermissionNames",qLogin.PermissionNames)>
		
		<cfset variables.SessionMgr.setValue("lastpageview",LoginTime)>
		
		<cfset variables.Users.saveRecord(UserID=qLogin.UserID,LastLogin=LoginTime)>
	
	<cfelse>
		<cfif arguments.ShowWhyFail>
			<!--- If login pwd creds didnt match --->
			<cfif variables.Users.hasUsers(username=arguments.username)>
				<cfset errMessage = "Invalid Password">
			<cfelse>
				<cfset errMessage = "Invalid Username">
			</cfif>
		<cfelse>
			<cfset errMessage = "Credentials Not found">
		</cfif>
		<cfthrow message="#errMessage#" type="LoginErr" errorcode="LoginErr">
	</cfif>
	
</cffunction>

<cffunction name="checkUserAllowed" access="public" returntype="boolean" output="no" hint="I check to see if the current user has been allocated any of the given permissions.">
	<cfargument name="Permissions" type="string" required="yes">
	
	<cfset var result = (
				Len(arguments.Permissions) EQ 0
			OR	(
						variables.SessionMgr.exists("PermissionNames")
					AND	Len(ListInCommon(variables.SessionMgr.getValue("PermissionNames"), arguments.Permissions)) GT 0
				)
	)>
	
	<cfreturn result>
</cffunction>

<cffunction name="getNoAccessURL" access="public" returntype="string" output="no">
	<cfargument name="ScriptName" type="string" default="">
	
	<cfset var result = "/">
	
	<cfset Arguments.ScriptName = makeRootPath(Arguments.ScriptName)>
	
	<cfif Left(Arguments.ScriptName,Len(Variables.SecureRoot)) EQ Variables.SecureRoot>
		<cfif Arguments.ScriptName EQ "#Variables.SecureRoot#index.cfm">
			<cfset result = "#Variables.SecureRoot#login.cfm">
		<cfelse>
			<cfset result = "#Variables.SecureRoot#index.cfm">
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getSecureRoot" access="public" returntype="string" output="no">
	
	<cfset var sThis = 0>
	<cfset var result = "">
	
	<cfif StructKeyExists(Variables,"SecureRoot")>
		<cfset result = Variables.SecureRoot>
	<cfelse>
		<cfset sThis = getMetadata(This)>
		<cfset result = sThis.name>
		<cfset result = ListDeleteAt(result,ListLen(result,"."),".")>
		<cfif ListLast(result,".") EQ "model">
			<cfset result = ListDeleteAt(result,ListLen(result,"."),".")>
		</cfif>
		<cfif ListLast(result,".") EQ "admins" OR ListLast(result,".") EQ "users">
			<cfset result = ListDeleteAt(result,ListLen(result,"."),".")>
		</cfif>
	</cfif>
	
	<cfset result = ListChangeDelims(result,"/",",")>
	<cfset result = ListChangeDelims(result,"/",".")>
	<cfset result = ListChangeDelims(result,"/","\")>
	
	<cfset result = makeRootPath(result,true)>
	
	<cfreturn result>
</cffunction>

<cffunction name="isSecuredPath" access="public" returntype="boolean" output="no">
	<cfargument name="ScriptName" type="string" default="">
	
	<cfset var keys = "">
	
	<cfset Arguments.ScriptName = makeRootPath(Arguments.ScriptName)>
	
	<cfif Left(Arguments.ScriptName,Len(Variables.SecureRoot)) EQ Variables.SecureRoot>
		<cfif ListLast(Arguments.ScriptName,"/") NEQ "login.cfm" AND ListLast(Arguments.ScriptName,"/") NEQ "logout.cfm">
			<cfreturn true>
		</cfif>
	<cfelseif StructKeyExists(Variables,"SecurePaths") AND isSimpleValue(Variables.SecurePaths)>
		<cfloop list="#Variables.SecurePaths#" index="key">
			<cfset key = makeRootPath(key)>
			<cfif Left(Arguments.ScriptName,Len(key)) EQ key>
				<cfreturn true>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn false>
</cffunction>

<cffunction name="isCurrent" access="public" returntype="boolean" output="no" hint="I check if the current user's login is current.">
	<cfargument name="TimeOut" type="numeric" required="yes">
	
	<cfset var lastview = now()>
	<cfset var isCurrent = true>
	
	<cfif variables.SessionMgr.exists("lastpageview")>
		<cfset lastview = variables.SessionMgr.getValue("lastpageview")>
		 <cfif DateDiff("n", lastview, Now()) GTE arguments.TimeOut>
			<cfset isCurrent = false>
			<cfset logout()>
		</cfif>
	<cfelse>
		<cfset isCurrent = false>
	</cfif>
	
	<cfset variables.SessionMgr.setValue("lastpageview",now())>
	
	<cfreturn isCurrent>
</cffunction>

<cffunction name="isLoggedIn" access="public" returntype="boolean" output="no">
	<cfargument name="AccessVars" type="string" default="AdminID" hint="A comma-delimited list of session variables that can be non-zero to allow access.">
	<cfargument name="TimeOut" type="numeric" default="90" hint="The time limit (in minutes) between page views for log in expiration.">
	
	<cfset var AccessVar = "">
	<cfset var result = false>
	
	<cfloop index="AccessVar" list="#arguments.AccessVars#">
		<cfif variables.SessionMgr.exists(AccessVar) AND variables.SessionMgr.getValue(AccessVar) NEQ 0>
			<cfset result = true>
			<cfif NOT isCurrent(arguments.TimeOut)>
				<cfset result = false>
				<cfset logout()>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfreturn result>
</cffunction>

<cffunction name="logout" access="public" returntype="void" output="no" hint="I log out the current user.">
	
	<cfscript>
	variables.SessionMgr.deleteVar('AdminID');
	variables.SessionMgr.deleteVar('FirstName');
	variables.SessionMgr.deleteVar('LastName');
	variables.SessionMgr.setValue("EzLOGIN_STATUS",0);
	</cfscript>

</cffunction>

<cffunction name="makeRootPath" access="private" returntype="string" output="no">
	<cfargument name="Path" type="string" required="true">
	<cfargument name="isDir" type="boolean" default="false">
	
	<cfif Left(Arguments.Path,1) NEQ "/">
		<cfset Arguments.Path = "/#Arguments.Path#">
	</cfif>
	<cfif Arguments.isDir AND Right(Arguments.Path,1) NEQ "/">
		<cfset Arguments.Path = "#Arguments.Path#/">
	</cfif>
	
	<cfreturn Arguments.Path>
</cffunction>

<cffunction name="upgrade" access="private" returntype="void" output="no">
	
	<cfset upgradeApproved()>
	
</cffunction>

<cffunction name="upgradeApproved" access="private" returntype="void" output="no">
	
	<cfset var sData = 0>
	
	<cfif Variables.Users.hasUsers() AND NOT Variables.Users.hasUsers(isApproved=1)>
		<cfset sData = StructNew()>
		<cfset sData["DateApproved"] = now()>
		<cfset Variables.DataMgr.updateRecords(tablename=Variables.Users.getTableVariable(),data_set=sData)>
	</cfif>
	
</cffunction>

<cffunction name="xml" access="public" output="yes">
<tables prefix="#variables.prefix#">
	<table entity="User" universal="true" labelField="FullName" sortfield="LastName" permissions="Users">
		<field name="username" type="text" label="User Name" Length="50" required="true" />
		<field name="password" type="password" label="Password" Length="25" required="true" />
		<field name="FirstName" type="text" label="First Name" Length="50" />
		<field name="LastName" type="text" label="Last Name" Length="50" />
		<field name="Email" type="email" Length="75" />
		<field name="LastLogin" type="date" sebfield="false" />
		<field name="DateCreated"  type="CreationDate" />
		<field name="isUniversal" type="boolean" label="Universal Admin?" Default="false" help="A universal admin has all permissions." />
		<field name="DateApproved"  type="date" label="Date Approved" />
		<field name="isApproved" label="Approved?">
			<relation type="has" field="DateApproved" />
		</field>
		<field name="FullName" label="Name">
			<relation type="concat" fields="FirstName,LastName" delimiter=" " />
		</field>
		<field name="LastNameFirst" label="Name">
			<relation type="concat" fields="LastName,FirstName" delimiter=", " />
		</field>
		<field fentity="Permission" jointype="many2many" />
		<data>
			<row username="admin" password="admin" FirstName="Admin" LastName="Admin" isUniversal="true" />
		</data>
	</table>
	<table entity="Permission" universal="true" Specials="Sorter" permissions="Permissions" />
</tables>
</cffunction>

<cfscript>

/**
 * Returns elements in list1 that are found in list2.
 * Based on ListCompare by Rob Brooks-Bilson (rbils@amkor.com)
 * 
 * @param List1      Full list of delimited values.  
 * @param List2      Delimited list of values you want to compare to List1.  
 * @param Delim1      Delimiter used for List1.  Default is the comma.  
 * @param Delim2      Delimiter used for List2.  Default is the comma.  
 * @param Delim3      Delimiter to use for the list returned by the function.  Default is the comma.  
 * @return Returns a delimited list of values. 
 * @author Michael Slatoff (rbils@amkor.commichael@slatoff.com) 
 * @version 1, August 20, 2001 
 */
function ListInCommon(List1, List2)
{
  var TempList = "";
  var Delim1 = ",";
  var Delim2 = ",";
  var Delim3 = ",";
  var i = 0;
  // Handle optional arguments
  switch(ArrayLen(arguments)) {
    case 3:
      {
        Delim1 = Arguments[3];
        break;
      }
    case 4:
      {
        Delim1 = Arguments[3];
        Delim2 = Arguments[4];
        break;
      }
    case 5:
      {
        Delim1 = Arguments[3];
        Delim2 = Arguments[4];          
        Delim3 = Arguments[5];
        break;
      }        
  } 
   /* Loop through the second list, checking for the values from the first list.
    * Add any elements from the second list that are found in the first list to the
    * temporary list
    */  
  for (i=1; i LTE ListLen(List2, "#Delim2#"); i=i+1) {
    if (ListFindNoCase(List1, ListGetAt(List2, i, "#Delim2#"), "#Delim1#")){
     TempList = ListAppend(TempList, ListGetAt(List2, i, "#Delim2#"), "#Delim3#");
    }
  }
  Return TempList;
}
</cfscript>

</cfcomponent>