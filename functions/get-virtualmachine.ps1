function get-virtualmachine {
    <#
    .DESCRIPTION
        resolves virtual machines by a given string.
    .PARAMETER Searchpattern
        a regex string
    .OUTPUTS
        returns an array of matching virtual machine names (domains)
    #>

    [cmdletbinding()]
    param (
        [ValidateNotNullOrWhiteSpace()][string]$SearchPattern = ".*"
    )

        ## load all existing vms
    [array]$VMList = @()
    foreach ($vm in $(sudo virsh list --all|select-object -skip 2).split([system.Environment]::NewLine,[StringSplitOptions]::removeEmptyEntries)) {
        $VMList += [PSCustomObject]@{
            VirtualMachineName = $vm.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[1]
            VirtualMachineStatus = $vm.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[2]
        }
    }

    ## filter list by searchPattern
    $ReturnArray = $VMList|where-object {$_.VirtualMachineName -match $SearchPattern}

    return $ReturnArray

}