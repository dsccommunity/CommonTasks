<#
    .SYNOPSIS
    Encrypt UserName & Password with a specified encryption key

    .DESCRIPTION
    This command will serialize an credential object, base 64 encode it and then encrypt
    so that it can be used as a string in a text-based file, like a Datum config file.

    To encrypt an builtin account specifiy the username and no or empty password.

    .PARAMETER User
    User Name

    .PARAMETER Password
    Password

    .EXAMPLE
    .\EncryptPwd4Yml.ps1

    .EXAMPLE
    .\EncryptPwd4Yml.ps1 'NT AUTHORITY\NetworkService'
#>

param(
    [parameter(Mandatory=$false, Position=0)]
    [string] $User = $null,

    [parameter(Mandatory=$false, Position=1)]
    [string] $Password = $null
)

if( -not (Get-Module ProtectedData -listavailable) )
{
    Install-Module ProtectedData -Scope CurrentUser
}

if( -not (Get-Module Datum.ProtectedData -listavailable) )
{
    Install-Module Datum.ProtectedData -Scope CurrentUser
}

if ( $User -ne $null -and $User.Length -ne "" )
{
    # if password is empty, create a dummy one to allow have credentias for system accounts: 
    #NT AUTHORITY\LOCAL SERVICE
    #NT AUTHORITY\NETWORK SERVICE
    if ($Password -eq $null -or $Password -eq "" )
    {
        $secpasswd = (New-Object System.Security.SecureString)
    }
    else
    {
        $secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force
    }
    $credential = New-Object System.Management.Automation.PSCredential ($User, $secpasswd)
}
else 
{
    $credential = Get-Credential -Message "Credentials are required."
}

#-- encrypt credentials --

$encryptionKey = Read-Host -AsSecureString -Prompt 'Encryption key for credential item'

$encCredential = $credential | Protect-Datum -Password $encryptionKey -MaxLineLength -1

"`nEncrypted Credential:`n`n`'$encCredential'"

#-- decrypt credentials for testing purposes --

$decryptionKey = Read-Host -AsSecureString -Prompt "`n`n------------------------------------`nReenter encryption key to test decryption: "

$decCredential = $encCredential | Unprotect-Datum -Password $decryptionKey

# for Powershell 5 - in Powershell 7 use: ConvertFrom-SecureString -SecureString $decCredential.Password -AsPlainText 
$decPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($decCredential.Password))

"`nUserName: $($decCredential.UserName)"
"Password: $decPwd"
