<#
.SYNOPSIS
    Script to create a random password. Incorporate into your script that creates new users to ensure new user objects are created with a strong and unique password.
.DESCRIPTION
    Incorporates uppercase letters, lowercase letters, numbers, and special character
    Gives control over how many are generated of each and how which characters to include or exclude
.NOTE
    Copyright (c) ZCSPM. All rights reserved.
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is  furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

.EXAMPLE
    New-Password -CountLower 6 -CountUpper 6 -CountNumber 6 -CountSpecial 6
#>

function New-Password {
    param(
        [int]$CountLower,
        [int]$CountUpper,
        [int]$CountNumber,
        [int]$CountSpecial
        )
    # initial variables
    $NewPassword = $null
    $Counter = 0

    # generate lower characters
    $VaildLower = "abcdefghijklmnopqrstuvwxyz"
    Do{
        $RandomLower = Get-Random -Minimum 0 -Maximum $VaildLower.Length
        $NewPassword += $VaildLower[$RandomLower]
        $LowerCounter++
    }
    Until($LowerCounter -eq $CountLower)

    # generate upper characters
    $VaildUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    Do{
        $RandomUpper = Get-Random -Minimum 0 -Maximum $VaildUpper.Length
        $NewPassword += $VaildUpper[$RandomUpper]
        $UpperCounter++
    }
    Until($UpperCounter -eq $CountUpper)
    
    # generate numbers characters
    $VaildNum = "1234567890"
    Do{
        $RandomNum = Get-Random -Minimum 0 -Maximum $VaildNum.Length
        $NewPassword += $VaildNum[$RandomNum]
        $NumberCounter++
    }
    Until($NumberCounter -eq $CountNumber)

    # generate special characters
    $VaildSpec = "!@#$%^&*()_+=-[]}{';/.,<>?"
    Do{
        $RandomSpec = Get-Random -Minimum 0 -Maximum $VaildSpec.Length
        $NewPassword += $VaildSpec[$RandomSpec]
        $SpecialCounter++
    }
    Until($SpecialCounter -eq $CountSpecial)

    # Password split into an array per single character
    $OrderedPassword = [regex]::split("$NewPassword", "(.)") -ne ''

    # Shuffle the array
    $OrderedPassword = $OrderedPassword | Sort-Object {Get-Random}

    # Shuffle the arrray again
    $RandomPassword = $OrderedPassword | Sort-Object {Get-Random}

    # join array back into a single string
    $RandomPassword -join ""

}

$WorkingDirectory = "C:\Windows\Temp"
$InFile = "Users_to_reset.csv"
$ErrorFile = "Users_to_reset_errors.txt"

$UsersToReset = (Import-Csv -Path "$WorkingDirectory\$InFile").SamAccountName

ForEach($UserToReset in $UsersToReset){
    
    Try{
        $NewPassword = New-Password -CountLower 6 -CountUpper 6 -CountNumber 6 -CountSpecial 2
    
        Set-ADAccountPassword -Identity $UserToReset -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$NewPassword" -Force)
    }
    Catch{
        $Error = $_.FullyQualifiedErrorId
        Add-Content -Path "$WorkingDirectory\$ErrorFile" -Value "$UserToReset|$Error"
    }

}
