<cf_PageController>

<cf_Template showTitle="true">

<p>
	You can manage administrators from here.
	It is highly advised that you create a separate account for each person who has access to that site
	rather than have multiple users share an account.
</p>

<cf_sebTable>
	<cf_sebColumn dbfield="LastNameFirst">
	<cf_sebColumn dbfield="username">
	<cf_sebColumn type="submit" show="!isApproved" label="Approve" CFC_Method="approveUser">
</cf_sebTable>

</cf_Template>