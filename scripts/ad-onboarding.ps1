# 1. Import the Active Directory module
Import-Module ActiveDirectory

# 2. Define the location of your mock employee data
$csvPath = "Desktop\employees.csv"

# 3. Read the CSV file
$employees = Import-Csv -Path $csvPath

# 4. Loop through each employee row in the file
foreach ($user in $employees) {
    
    # Generate clean, standard corporate data variables
    $firstname = $user.FirstName
    $lastname = $user.LastName
    $dept = $user.Department
    $title = $user.JobTitle
    
    # Create standard SAM account username format (e.g., sconnor, jconnor)
    $username = ($firstname.Substring(0,1) + $lastname).ToLower()
    
    # Create an identifiable display name string
    $displayName = "$firstname $lastname"
    
    # Establish a default secure password string for new accounts
    $securePassword = ConvertTo-SecureString "Welcome2026!" -AsPlainText -Force
    
    # Check if the Department folder (Organizational Unit) already exists. If not, create it.
    $ouPath = "OU=$dept,DC=corp,DC=local"
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$dept'")) {
        Write-Host "Creating target Organizational Unit folder: $dept" -ForegroundColor Cyan
        New-ADOrganizationalUnit -Name $dept -Path "DC=corp,DC=local"
    }
    
    # Check if the user already exists to avoid duplication errors
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$username'")) {
        
        Write-Host "Onboarding User: $displayName ($username) into $dept department..." -ForegroundColor Green
        
        # Execute the Active Directory object creation command
        New-ADUser -Name $displayName `
                   -SamAccountName $username `
                   -UserPrincipalName "$username@corp.local" `
                   -GivenName $firstname `
                   -Surname $lastname `
                   -DisplayName $displayName `
                   -Title $title `
                   -Department $dept `
                   -Path $ouPath `
                   -AccountPassword $securePassword `
                   -ChangePasswordAtLogon $true `
                   -Enabled $true
    } else {
        Write-Host "User Account $username already exists in the system. Skipping." -ForegroundColor Yellow
    }
}
