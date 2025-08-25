function new-snapshot {
    <#
    .Description
        Creates a Snapshot for a each given virtual machine
    .Parameter VirtualMachineNames (Alias vms)
        Mandatory
        an array of machine names
        if empty all machines will be listed
    .PARAMETER SnapshotName
        a string value containgin a name for the snapshot
        if empty a generic name is generated
    .OUTPUTS
        an array of given Machines with the status of the operation
    .NOTES
        The given list of machines is validated against existing machines.
        
    #>

    param (
        [alias("vms")][array]$VirtualMachineNames = @($(sudo virsh list --all|select-object -skip 2).split([system.Environment]::NewLine,[StringSplitOptions]::removeEmptyEntries)|foreach-object { $_.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[1] }),
        [string]$SnapShotname = $("Generic-$(get-date -format "yyyy-MMM-dd-hhmm")")
    )

 ## load all existing vms
    [array]$VMList = @()
    foreach ($vm in $(sudo virsh list --all|select-object -skip 2).split([system.Environment]::NewLine,[StringSplitOptions]::removeEmptyEntries)) {
        $VMList += [PSCustomObject]@{
            VirtualMachineName = $vm.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[1]
            VirtualMachineStatus = $vm.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[2]
        }
    }
    ## filter requested
    $VMList = $VMList|where-object {$VirtualMachineNames -contains $_.VirtualMachineName}
    
    $ReturnArray = @()
    if ($VMList.count -gt 0 ) {
        foreach ( $vm in $VMList) {
            write-verbose "Processing $($vm.VirtualMachineName)"
            ## Create new Snapshot for machine
            $ReturnArray += @($(sudo virsh snapshot-create-as $vm.VirtualMachineName --name $SnapShotname --description "Created By Jenkins Job ${ENV:BUILD_NUMBER}" ))

        }
    }
 return $ReturnArray
}