
Properties {

    $ModuleNames    = 'GraylogSidecarDsc'
    $ModuleMerge    = $false

    $GalleryEnabled = $true
    $GalleryKey     = Use-VaultSecureString -TargetName 'PowerShell Gallery Key (arcadesolutionsag)'

    $GitHubEnabled  = $true
    $GitHubRepoName = 'arcadesolutionsag/GraylogSidecarDsc'
    $GitHubToken    = Use-VaultSecureString -TargetName 'GitHub Token (arcadesolutionsag)'
}
