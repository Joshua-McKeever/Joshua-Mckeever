<#
.SYNOPSIS
    Function to create a new share folder, including the security groups, assign security groups with permissions, and if specified grant the owner rights to the group
.DESCRIPTION
    In share folder structure flat is better, this function will create a new shared folder at
    the root of a pre-defined folder, along with the corresponding ad groups for best practice management
.NOTE
    Copyright (c) ZCSPM. All rights reserved.
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is  furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

.EXAMPLE
    New-ShareDriveFolder -PreProposedName "Birthday Parties"

.EXAMPLE
    $NewFolders = @('Minecraft', 'PalWorld')

    ForEach($NewFolder in $NewFolders){
        New-ShareDriveFolder -PreProposedName "$NewFolder" -Owner "U000001"
    }
#>

function New-ShareDriveFolder {

param(
    [Parameter(Mandatory = $true)] [String] $PreProposedName,
    [Parameter()] [String] $Owner
)

# Define function to create new Universal ID
function New-UniversalID {
    param( [int]$Length )
    $ValidChar = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    $UniversalID = $null
    $Counter = 0

    Do{
        $RandomChar = Get-Random -Minimum 0 -Maximum $ValidChar.Length
        $UniversalID += $ValidChar[$RandomChar]
        $Counter++
    }
    Until($Counter -eq $Length)

    $UniversalID
}

# specify root folder
$RootFolder = "C:\NAS"

# Check for and create new folder
$DirItems = Get-ChildItem -Path "$RootFolder"
$ExistingFolders = $DirItems.Name
$LongProposedName = $PreProposedName -replace '[^a-zA-Z0-9]', '_'

# Foldername cannot exceed 40 characters
If($LongProposedName.Length -gt 40){
    $ProposedName = $LongProposedName.Substring(0,40)
}
Else{
    $ProposedName = $LongProposedName
}

# Foldername cannont already exist
If($ProposedName -in $ExistingFolders){
    $Append = New-UniversalID -Length 3
    $FolderName = $ProposedName + "-DUP-" + $Append
}
Else{
    $FolderName = $ProposedName
}

$CreateDirResult = New-Item -Path "$RootFolder" -Name "$FolderName" -ItemType "directory"

$NewDirName = $CreateDirResult.Name

# Create AD Groups and set ACL
$DefaultRoles = @('RO', 'RW')

ForEach($DefaultRole in $DefaultRoles){

    switch ( $DefaultRole )
    {
        "RO" { $Permission = "ReadAndExecute" }
        "RW" { $Permission = "Modify" }
    }

    $NextGroup = "SHR-NAS_" + "$NewDirName" + "-$DefaultRole"
    New-ADGroup -Name $NextGroup -SamAccountName $NextGroup -GroupCategory Security -GroupScope Global -Path "OU=MyGroups,DC=genericco,DC=com" -Description "$RootFolder\$NewDirName" -OtherAttributes @{'Info'="$Permission permissions on $RootFolder\$NewDirName"}
    
    # Configure ACL
    $Acl = Get-Acl -Path "$RootFolder\$NewDirName"
    $Acl.SetAccessRuleProtection($False, $False)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("genericco.com\$NextGroup","$Permission","ContainerInherit, ObjectInherit","None","Allow")
    $Acl.AddAccessRule($AccessRule)
    $Acl | Set-Acl "$RootFolder\$NewDirName"

    # if owner specified update member and managedBy attributes
    If($Owner){
        Set-ADGroup $NextGroup -Replace @{managedBy = (Get-ADUser $Owner).DistinguishedName; member = (Get-ADUser $Owner).DistinguishedName}
    }

}


$NewDirName
}
