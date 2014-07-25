<cf_PageController>
<cf_Template>

<cfif Len(Alert)>
	<p class="sebError"><cfoutput>#Alert#</cfoutput></p>
</cfif>

<cfif hasPermissionsPermission>
	<p>The "Permissions" permission gives a user the ability to change their permission or that of anyone else. It is effectively the skeleton key.</p>	
</cfif>

<cf_sebForm>
	<cf_sebField name="username">
	<cf_sebField name="password">
	<cf_sebField name="FirstName">
	<cf_sebField name="LastName">
	<cf_sebField name="Email">
	<cfif isUserUniversal>
		<cf_sebField name="isUniversal" onclick="showPermissions();">
	</cfif>
	<cf_sebField name="Permissions">
	<cf_sebField type="submit/cancel/delete">
</cf_sebForm>

</cf_Template>