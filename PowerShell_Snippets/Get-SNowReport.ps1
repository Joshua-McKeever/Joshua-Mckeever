<#
.SYNOPSIS
    Function to download a ServiceNow report
.DESCRIPTION
    A quick workaround to querying and paging through thousands of users with ServiceNow is to
    simply download a pre-defined report and working programatically with the report as an object
.NOTE
    Copyright (c) ZCSPM. All rights reserved.
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is  furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

.EXAMPLE
    Get-SNowReport -SNowUserName "myUserName" -SNowPassword "myPassword" -SNowSubdomain "my-company" -SNowReportID "fc23e6a887fd0d902aed0e58cebb3513" -FileName "myReport.csv"

#>

function Get-SNowReport {
    [Parameter(Mandatory = $true)] [String] $SNowUserName,
    [Parameter(Mandatory = $true)] [String] $SNowPassword,
    [Parameter(Mandatory = $true)] [String] $SNowSubdomain,
    [Parameter(Mandatory = $true)] [String] $SNowReportID,
    [Parameter(Mandatory = $true)] [String] $FileName



    # hard coding credentials is bad practice and not secure
    # consider pulling these credentials 'just in time'
    $user = "$SNowUserName"
    $pass = "$SNowPassword"
 
    # Build auth header
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))
 
    # Set proper headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
    $headers.Add('Accept','application/json')
    $headers.Add('Content-Type','application/json')

    $URI = "https://$SNowSubdomain.service-now.com/sys_report_template.do?CSV&jvar_report_id=$SNowReportID"

    Invoke-WebRequest -Uri $URI -Headers $Headers -OutFile "C:\Users\$ENV:UserName\Downloads\$FileName"
}
