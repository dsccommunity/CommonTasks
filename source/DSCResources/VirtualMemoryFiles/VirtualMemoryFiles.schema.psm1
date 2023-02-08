<#
    - Drive: [String] The drive letter for which paging settings should be set. Can be letter only, letter and colon or letter with colon and trailing slash.
      Type: [String] AutoManagePagingFile, CustomSize, SystemManagedSize, NoPagingFile
      InitialSize: [SInt64] The initial size of the page file in Megabyte
      MaximumSize: [SInt64] The maximum size of the page file in Megabyte
#>

configuration VirtualMemoryFiles
{
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Files
    )

    $curPSModulePath = $env:PSModulePath

    Import-DscResource -ModuleName ComputerManagementDsc

    foreach ($file in $Files)
    {
        $executionName = $file.Drive
        (Get-DscSplattedResource -ResourceName VirtualMemory -ExecutionName $executionName -Properties $file -NoInvoke).Invoke($file)
    }

    # restore PSModulePath to reset changes made during MOF compilation
    $env:PSModulePath = $curPSModulePath
}
