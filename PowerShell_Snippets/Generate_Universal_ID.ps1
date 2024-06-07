<#
.SYNOPSIS
    Function to create a random alpha numeric
.DESCRIPTION
    When creating a 10 character alpha numeric, the chances of repeating a string are 1/3,656,158,440,062,980
    Use this function when needing to assign unique IDs. Optional prefix if needing to standardize the prefix for organizational purposes
.NOTE
    Copyright (c) ZCSPM. All rights reserved.
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is  furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

.EXAMPLE
    New-UniversalID -Length 10
#>

function New-UniversalID {
    param( [int]$Length )
    $ValidChar = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    $UniversalID = $null
    $Counter = 0
    # optional, add prefix here e.g. A- for 'assocaite'
    $Prefix = ""

    Do{
        $RandomChar = Get-Random -Minimum 0 -Maximum $ValidChar.Length
        $UniversalID += $ValidChar[$RandomChar]
        $Counter++
    }
    Until($Counter -eq $Length)

    $Prefix + $UniversalID
}

New-UniversalID -Length 10
