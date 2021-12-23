param
(
    [Parameter()]
    [System.String]
    $BuiltModuleSubdirectory = (property BuiltModuleSubdirectory ''),

    [Parameter()]
    [System.Management.Automation.SwitchParameter]
    $VersionedOutputDirectory = (property VersionedOutputDirectory $true),

    [Parameter()]
    [System.String]
    $ProjectName = (property ProjectName ''),

    [Parameter()]
    [System.String]
    $SourcePath = (property SourcePath ''),

    [Parameter()]
    $ChangelogPath = (property ChangelogPath 'CHANGELOG.md'),

    [Parameter()]
    $ReleaseNotesPath = (property ReleaseNotesPath (Join-Path $OutputDirectory 'ReleaseNotes.md')),

    [Parameter()]
    [string]
    $GitHubToken = (property GitHubToken ''), # retrieves from Environment variable

    [Parameter()]
    [string]
    $ReleaseBranch = (property ReleaseBranch 'main'),

    [Parameter()]
    [string]
    $GitHubConfigUserEmail = (property GitHubConfigUserEmail ''),

    [Parameter()]
    [string]
    $GitHubConfigUserName = (property GitHubConfigUserName ''),

    [Parameter()]
    $GitHubFilesToAdd = (property GitHubFilesToAdd ''),

    [Parameter()]
    $BuildInfo = (property BuildInfo @{ }),

    [Parameter()]
    $SkipPublish = (property SkipPublish ''),

    [Parameter()]
    $MainGitBranch = (property MainGitBranch 'main')
)

task UpdateTag -if ($GitHubToken -and (Get-Module -Name PowerShellForGitHub)) {
    # # This is how AzDO setup the environment:
    # git init
    # git remote add origin https://github.com/gaelcolas/Sampler
    # git config gc.auto 0
    # git config --get-all http.https://github.com/gaelcolas/Sampler.extraheader
    # git @('pull', 'origin', $MainGitBranch)
    # # git fetch --force --tags --prune --progress --no-recurse-submodules origin
    # # git @('checkout', '--progress', '--force' (git @('rev-parse', "origin/$MainGitBranch")))

    . Set-SamplerTaskVariable
    $env:GCM_PROVIDER = 'generic'
    git fetch --all --tags
    git ls-remote --tags origin
    #--points-at <object>
    git describe --tags

    git tag $ModuleVersion





    &git @('config', 'user.name', $GitHubConfigUserName)
    &git @('config', 'user.email', $GitHubConfigUserEmail)
    &git @('config', 'pull.rebase', 'true')
    &git @('pull', 'origin', $MainGitBranch, '--tag')
    # Look at the tags on latest commit for origin/$MainGitBranch (assume we're on detached head)
    Write-Build DarkGray "git rev-parse origin/$MainGitBranch"
    $MainHeadCommit = (git @('rev-parse', "origin/$MainGitBranch"))
    Write-Build DarkGray "git tag -l --points-at $MainHeadCommit"
    $TagsAtCurrentPoint = git @('tag', '-l', '--points-at', $MainHeadCommit)
    Write-Build DarkGray ($TagsAtCurrentPoint -join '|')

    try
    {
        $remoteURL =  [URI](git remote get-url origin)
        $repoInfo = Get-GHOwnerRepoFromRemoteUrl -RemoteUrl $remoteURL

        $URI = $remoteURL.Scheme + [URI]::SchemeDelimiter + $GitHubToken + '@' + $remoteURL.Authority + $remoteURL.PathAndQuery

        # Update the PUSH URI to use the Personal Access Token for Auth
        git remote set-url --push origin $URI

        # track this branch on the remote 'origin
        git push origin --tags

        Write-Build Green "Tag $ModuleVersion pushed"
    }
    catch
    {
        Write-Build Red "Error pushing tag $ModuleVersion.`r`n $_"
    }
}

task SetChangeLog -if ($GitHubToken -and (Get-Module -Name PowerShellForGitHub)) {
    # # This is how AzDO setup the environment:
    # git init
    # git remote add origin https://github.com/gaelcolas/Sampler
    # git config gc.auto 0
    # git config --get-all http.https://github.com/gaelcolas/Sampler.extraheader
    # git @('pull', 'origin', $MainGitBranch)
    # # git fetch --force --tags --prune --progress --no-recurse-submodules origin
    # # git @('checkout', '--progress', '--force' (git @('rev-parse', "origin/$MainGitBranch")))

    . Set-SamplerTaskVariable

    $ChangelogPath = Get-SamplerAbsolutePath -Path $ChangeLogPath -RelativeTo $ProjectPath
    "`Changelog Path                 = '$ChangeLogPath'"

    foreach ($GitHubConfigKey in @('GitHubFilesToAdd', 'GitHubConfigUserName', 'GitHubConfigUserEmail', 'UpdateChangelogOnPrerelease'))
    {
        if ( -Not (Get-Variable -Name $GitHubConfigKey -ValueOnly -ErrorAction SilentlyContinue))
        {
            # Variable is not set in context, use $BuildInfo.GitHubConfig.<varName>
            $ConfigValue = $BuildInfo.GitHubConfig.($GitHubConfigKey)
            Set-Variable -Name $GitHubConfigKey -Value $ConfigValue
            Write-Build DarkGray "`t...Set $GitHubConfigKey to $ConfigValue"
        }
    }

    &git @('config', 'user.name', $GitHubConfigUserName)
    &git @('config', 'user.email', $GitHubConfigUserEmail)
    &git @('config', 'pull.rebase', 'true')
    &git @('pull', 'origin', $MainGitBranch, '--tag')
    # Look at the tags on latest commit for origin/$MainGitBranch (assume we're on detached head)
    Write-Build DarkGray "git rev-parse origin/$MainGitBranch"
    $MainHeadCommit = (git @('rev-parse', "origin/$MainGitBranch"))
    Write-Build DarkGray "git tag -l --points-at $MainHeadCommit"
    $TagsAtCurrentPoint = git @('tag', '-l', '--points-at', $MainHeadCommit)
    Write-Build DarkGray ($TagsAtCurrentPoint -join '|')

    # Only Update changelog if last commit is a full release
    if ($UpdateChangelogOnPrerelease)
    {
        $TagVersion = [string]($TagsAtCurrentPoint | Select-Object -First 1)
        Write-Build Green "Updating Changelog for PRE-Release $TagVersion"
    }
    elseif ($TagVersion = [string]($TagsAtCurrentPoint.Where{ $_ -notMatch 'v.*\-' }))
    {
        Write-Build Green "Updating the ChangeLog for release $TagVersion"
    }
    else
    {
        Write-Build Yellow "No Release Tag found to update the ChangeLog from in '$TagsAtCurrentPoint'"
        return
    }

    #$BranchName = "updateChangelogAfter$TagVersion"
    Write-Build DarkGray "Creating branch $BranchName"

    #git checkout -B $BranchName

    try
    {
        Write-Build DarkGray "Updating Changelog file"
        Update-Changelog -ReleaseVersion ($TagVersion -replace '^v') -LinkMode None -Path $ChangelogPath -ErrorAction SilentlyContinue
        git add $GitHubFilesToAdd
        git commit -m "Updating ChangeLog since $TagVersion +semver:skip"

        $remoteURL =  [URI](git remote get-url origin)
        $repoInfo = Get-GHOwnerRepoFromRemoteUrl -RemoteUrl $remoteURL

        $URI = $remoteURL.Scheme + [URI]::SchemeDelimiter + $GitHubToken + '@' + $remoteURL.Authority + $remoteURL.PathAndQuery

        # Update the PUSH URI to use the Personal Access Token for Auth
        git remote set-url --push origin $URI

        # track this branch on the remote 'origin
        git push #-u origin $BranchName

        #$NewPullRequestParams = @{
        #    AccessToken         = $GitHubToken
        #    OwnerName           = $repoInfo.Owner
        #    RepositoryName      = $repoInfo.Repository
        #    Title               = "Updating ChangeLog since release of $TagVersion"
        #    Head                = $BranchName
        #    Base                = $MainGitBranch
        #    ErrorAction         = 'Stop'
        #    MaintainerCanModify = $true
        #}

        #$Response = New-GitHubPullRequest @NewPullRequestParams
        #Write-Build Green "`n --> PR #$($Response.number) opened: $($Response.url)"
        Write-Build Green 'Changelog changes pushed'
    }
    catch
    {
        Write-Build Red "Error trying to create ChangeLog Pull Request. Ignoring.`r`n $_"
    }
}
