# Declare DSInternals as the required module.
# https://github.com/MichaelGrafnetter/DSInternals
#requires -Modules DSInternals

# Add the required parameters
param (
    # Accepts the domain controller's hostname (e.g., dc1.contoso.com)
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $DomainController,
    # Accepts the domain partition naming context (e.g., dc=contoso,dc=com)
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $NamingContext,
    # Accepts the location or path of the weak password list File (i.e., the NSCS Top 100,000 Breached (Pwned) Passwords)
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $WeakPasswordsFile,
    # Accepts the output file path for the CSV
    [parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $OutputFile
)

# BEGIN WEAK AD PASSWORD TEST
$failedPasswords = (
    # GET ALL AD USER ACCOUNTS
    Get-ADReplAccount -All -Server $DomainController -NamingContext $NamingContext |
        Where-Object { $_.SamAccountType -eq 'User' } |

    # TEST ALL USERS' PASSWORD QUALITY
    Test-PasswordQuality -IncludeDisabledAccounts -WeakPasswordsFile $WeakPasswordsFile

).WeakPassword

$usersWithFailedPasswords = @()

# Loop through each failed password
foreach ($i in $failedPasswords) {
    $username = $i.Username

    # Get the user account by SamAccountName
    $user = Get-ADUser -Filter "SamAccountName -eq '$username'" -Server $DomainController

    if ($user) {
        $userWithLastSet = [PSCustomObject]@{
            Username = $username
            PasswordLastSet = $user.PasswordLastSet
        }

        $usersWithFailedPasswords += $userWithLastSet
    }
}

# Export the result to a CSV file
$usersWithFailedPasswords | Export-Csv -Path $OutputFile -NoTypeInformation
