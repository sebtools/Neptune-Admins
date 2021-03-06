<cfcomponent displayname="Permissions Manager" extends="com.sebtools.Records" output="no">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="Manager" type="any" required="yes">
	
	<cfset initInternal(argumentCollection=arguments)>
	
	<cfreturn this>
</cffunction>

<cffunction name="savePermission" access="public" returntype="numeric" output="no">
	
	<cfset var result = saveRecord(argumentCollection=arguments)>
	
	<cfset assignPermissions()>
	
	<cfreturn result>
</cffunction>

<cffunction name="assignPermissions" access="private" returntype="void" output="no" hint="I assign all permissions to all universal users.">
	
	<cfset var qPermissions = getPermissions(fieldlist="PermissionID")>
	
	<!--- Make sure that universal admins get all permissions --->
	<cfset variables.DataMgr.updateRecords(
		tablename = variables.Parent.Users.getTableVariable(),
		data_set = StructFromArgs(Permissions=ValueList(qPermissions.PermissionID)),
		data_where = StructFromArgs(isUniversal=true)
	)>
	
</cffunction>

<cffunction name="hasPermission" access="public" returntype="boolean">
	<cfargument name="PermissionList" type="string" required="yes">
	<cfargument name="UserPermissions" type="string" required="yes">
	
	<cfset var permitted = false>
	<cfset var UserPermission = "">

	<cfloop list="#arguments.UserPermissions#" index="UserPermission">
		<cfif ListFindNoCase(arguments.PermissionList,UserPermission)>
			<cfset permitted = true>
			<cfbreak>
		</cfif>
	</cfloop>
	
	<cfreturn permitted>
</cffunction>

</cfcomponent>