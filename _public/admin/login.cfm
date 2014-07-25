<cf_PageController>

<cf_Template use="Default" title="Login">

<cfoutput>
<h1>#variables.SiteName# Administrative Area</h1>

<p>This is the administrative area of the #variables.SiteName# site. If you have questions about this area or need to be granted access, contact the site administrator</p>
<p>If you have been granted access to this area of the site, please fill in your username and password.</p>
</cfoutput>

<cf_sebForm
	formname="frmLogin"
	CFC_Component="#Application.Security#"
	CFC_Method="checkLogin"
	CatchErrTypes="LoginErr"
>
	<cf_sebField name="username" label="Username">
	<cf_sebField name="password" label="Password" type="password">
	<cf_sebField type="submit" label="Submit">
</cf_sebForm>

<script type="text/javascript">document.forms.frmLogin.username.focus();</script>

</cf_Template>