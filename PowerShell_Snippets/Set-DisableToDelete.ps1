<#
.SYNOPSIS
    Function to identify stale AD groups, rename them, and move them to a holding OU
.DESCRIPTION
    Deleting AD groups can have downstream impact, please consider ramifications before implementing
    Renaming preior to deletion is one of the best ways to ensure the group is not in use prior to deletion
    The function will hold the group in the holding OU for the same time period that a group is considered stale
    e.g. a group is stale after 60 days, Day 1 no action, Day 60 with no inactivity group will be renamed, Day 120 with no inactivity the group will be deleted
.NOTE
    Copyright (c) ZCSPM. All rights reserved.
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is  furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

.EXAMPLE
    Set-DisableToDelete -DaysStale -30 -SearchBase "OU=MyGroups,DC=genericco,DC=com" -DisabledOU "OU=DisableToDelete,DC=genericco,DC=com"

#>

function Set-DisableToDelete {

param(
    [Parameter(Mandatory = $true)] [Int] $DaysStale,
    [Parameter(Mandatory = $true)] [String] $SearchBase,
    [Parameter(Mandatory = $true)] [String] $DisabledOU
)

$StaleDate = (Get-Date).AddDays($DaysStale)
$DtD_OU = "$DisabledOU"

# identify stale AD groups, rename them, and move them

$data = Get-ADGroup -Filter * -SearchBase $SearchBase -Properties whenChanged, whenCreated | Select Name, DistinguishedName, whenChanged, whenCreated
$StaleGroups = $data | Where-Object whenChanged -LE $StaleDate | Select DistinguishedName, Name -First 1
$RemediatedStaleGroups = @()
ForEach($StaleGroup in $StaleGroups){
    $DN = $StaleGroup.DistinguishedName
    $Name = $StaleGroup.Name
    $NewName = "Dtd$Name"
    Set-ADGroup -Identity "$DN" -SamAccountName "$NewName"
    Rename-ADObject -Identity "$DN" -NewName "$NewName"

    $NewDN = "CN=$NewName,$SearchBase"
    Move-ADObject -Identity "$NewDN" -TargetPath $DtD_OU


    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name NewName -value "$NewName"
    $obj | Add-Member -MemberType NoteProperty -Name OldDN -Value "$DN"

    $RemediatedStaleGroups += $obj

}

$RemediatedStaleGroups

# identify super stale AD groups, delete them
$DtD_Candidates = Get-ADGroup -Filter * -SearchBase $DtD_OU -Properties whenChanged, whenCreated | Select Name, DistinguishedName, whenChanged, whenCreated
$SuperStaleDate = $StaleDate.AddDays($DaysStale)
$SuperStaleGroups = $DtD_Candidates | Where-Object whenChanged -LE $SuperStaleDate | Select DistinguishedName, Name -First 1
$DeletedGroups = @()
ForEach($SuperStaleGroup in $SuperStaleGroups){
    $SS_DN = $SuperStaleGroup.DistinguishedName
    $SS_Name = $SuperStaleGroup.Name
    
    Remove-ADGroup -Identity $SS_DN -Confirm:$false
    
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name DeletedName -value "$SS_Name"
    $obj | Add-Member -MemberType NoteProperty -Name DeletedDN -Value "$SS_DN"

    $DeletedGroups += $obj

}

$DeletedGroups
}
