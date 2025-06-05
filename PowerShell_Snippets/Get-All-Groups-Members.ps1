$TempFile = "C:\Downloads\All_Groups.csv"
$OutFIle = "C:\Downloads\GroupMembers.csv"

# Export list of all AD Groups
Get-ADGroup -Filter * | Select DistinguishedName | Export-CSV $TempFile -NoTypeInformation

# Iterate through each group and extract active members
$SourceGroups = Import-CSV $TempFile
ForEach($SourceGroup in $SourceGroups){

    $CurrentGroup = $SourceGroup.DistinguishedName
    $LDAPfilter = "(&(objectCategory=person)(objectClass=user)(!(userAccountControl:1.2.840.113556.1.4.803:=2))(memberOf=$CurrentGroup))"
    Get-ADUser -LDAPFilter $LDAPfilter -SearchBase "DC=[your company],DC=org" | Select @{Name = "GroupDN"; Expression = {$CurrentGroup}}, SamAccountName, Company, physicalDeliveryOfficeName, Department, Title | Export-Csv $OutFIle -Append

}
