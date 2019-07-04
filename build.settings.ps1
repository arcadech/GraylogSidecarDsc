
Properties {

    $ModuleNames    = 'GraylogSidecardDsc'
    $ModuleMerge    = $false

    $GalleryEnabled = $true
    $GalleryKey     = Use-VaultSecureString -TargetName 'PowerShell Gallery Key (arcadesolutionsag)'

    $GitHubEnabled  = $true
    $GitHubRepoName = 'arcadesolutionsag/GraylogSidecardDsc'
    $GitHubToken    = Use-VaultSecureString -TargetName 'GitHub Token (arcadesolutionsag)'
}
