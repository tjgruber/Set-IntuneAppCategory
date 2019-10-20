<####################################################
# SET INTUNE APP CATEGORY
####################################################>
function Set-IntuneAppCategory {
<#
.SYNOPSIS
	Adds or removes an Intune Win32 LoB app to or from an Intune app category.
.DESCRIPTION
	Adds or removes an Intune Win32 LoB app to or from an Intune app category based on a CategoryName match or exact CategoryId parameter.
.PARAMETER CategoryName
	The name of the category to match.
.PARAMETER CategoryId
	The ID of the category. This needs to be exact.
.PARAMETER Add
	Adds specified app to specified category.
.PARAMETER Remove
    Removes specified app to specified category.
.PARAMETER AppId
	The ID of the app.
.EXAMPLE
	Set-IntuneAppCategory -CategoryName "Test group 0" -Add -AppId "863f02ca-baba-4798-c20b-cbac4230c0bd"
.EXAMPLE
	Set-IntuneAppCategory -CategoryName "Test group 0" -Remove -AppId "863f02ca-baba-4798-c20b-cbac4230c0bd"
.NOTES
	This is designed as an internal script function rather than a stand-alone function, but will work if you input the correct parameters.
.LINK
	https://TimothyGruber.com
#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ParameterSetName='CategoryName')]
        [string]$CategoryName,
        [Parameter(Mandatory,ParameterSetName='CategoryId')]
        [string]$CategoryId,
        [Parameter()]
        [switch]$Add,
        [Parameter()]
        [switch]$Remove,
        [Parameter(Mandatory)]
        [string]$AppId
    )
    if ($CategoryName) {
        $intuneAppGetCategoryNameIdUri = 'https://graph.microsoft.com/beta/deviceAppManagement/mobileAppCategories'
        $intuneAppGetCategoryNameIdRequest = @{
            ContentType = "application/json";
            Method = "Get";
            Uri = $intuneAppGetCategoryNameIdURI;
            ErrorAction = "SilentlyContinue";
            ErrorVariable = "intuneAppGetCategoryNameIdERR"
        }
        Invoke-GraphAPIAuthTokenCheck
        $setintuneAppGetCategoryNameIdDATA = (Invoke-RestMethod -Headers $global:graphAPIReqHeader @intuneAppGetCategoryNameIdRequest)
        if ($intuneAppGetCategoryNameIdERR) {
            Write-Output "...ERROR - There was a problem retrieving setintuneAppGetCategoryNameIdDATA - [$intuneAppGetCategoryNameIdERR]"
        }
        $matchedCategoryNameId = $setintuneAppGetCategoryNameIdDATA.value | Where-Object {$_.displayName -match $CategoryName}
        if (-not($matchedCategoryNameId)) {
            Write-Output "...ERROR - Could not match input of [$CategoryName] to an Intune Mobile App Category."
        }
        $intuneAppGetCategoryIdUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileAppCategories/$($matchedCategoryNameId.id)"
        $CategoryId = $matchedCategoryNameId.id
    }
    if ($Add) {
        $requestMethod = "Post"
        $intuneAppAddCategoryUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$appId/categories/`$ref"
        $intuneAppAddCategoryBody = @{
            '@odata.id' = $intuneAppGetCategoryIdUri
        }
        $intuneAppSetCategoryRequest = @{
            ContentType = "application/json";
            Body = ($intuneAppAddCategoryBody | ConvertTo-Json);
            Method = $requestMethod;
            Uri = $intuneAppAddCategoryUri;
            ErrorAction = "SilentlyContinue";
            ErrorVariable = "intuneAppCategoryERR"
        }
    }
    if ($Remove) {
        $requestMethod = "Delete"
        $intuneAppRemoveCategoryUri = "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$appId/categories/$categoryId/`$ref"
        $intuneAppSetCategoryRequest = @{
            ContentType = "application/json";
            Method = $requestMethod;
            Uri = $intuneAppRemoveCategoryUri;
            ErrorAction = "SilentlyContinue";
            ErrorVariable = "intuneAppCategoryERR"
        }
    }
    Invoke-GraphAPIAuthTokenCheck
    $setintuneAppSetCategoryIdDATA = (Invoke-RestMethod -Headers $global:graphAPIReqHeader @intuneAppSetCategoryRequest)
    if ($intuneAppCategoryERR) {
        Write-Output "...ERROR - There was a problem retrieving setintuneAppSetCategoryIdDATA - [$intuneAppCategoryERR]"
    }
}