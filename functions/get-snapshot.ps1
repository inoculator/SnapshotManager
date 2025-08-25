function get-snapshot {
    <#
    .Description
        Loads all machines and scans for existing snapshots
    .outputs
        an array of machines with snapshots and status
    .PARAMETER VirtualMachineNames
        alias: vms
        and array of virtual machine names
        if empty all machines will be listed
    
    .NOTES
        virsh does not output as object with powershell.
        It is pure ascii formatted text.
        Therefor a lot of StringSplitOptions are needed to put it into a propper PoSh array.

    #>
    [cmdletbinding()]
    param (
        [Alias("vms")][array]$VirtualMachineNames = @($(sudo virsh list --all|select-object -skip 2).split([system.Environment]::NewLine,[StringSplitOptions]::removeEmptyEntries)|foreach-object { $_.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[1] })
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
            write-verbose "GET-SNAPSHOT: Processing $($vm.VirtualMachineName)"
            ## loading snapshots for each vm
            [array]$SnapShotList = @($(sudo virsh snapshot-list $($vm.VirtualMachineName)|select-object -skip 2).split([system.Environment]::NewLine,[StringSplitOptions]::removeEmptyEntries))
            ## converting each entry to a named array
            $SnapShotArray = @()
            write-verbose "Found $($SnapshotList.count) Snapshots"
            foreach ($SnapShot in $SnapShotList) {
                write-verbose "GET-SNAPSHOT: processing $snapshot"
                $SnapShotArray += [PSCustomObject]@{
                    Name = $SnapShot.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[0]
                    Date = $SnapShot.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[1,2,3] -join " "|get-date
                    Status = $SnapShot.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[4]
                }
            }
            $ReturnArray += [PSCustomObject]@{
                VirutalMachineName = $vm.VirtualMachineName
                VirtualMachineStatus = $vm.VirtualMachineStatus
                SnapShotList = $SnapShotArray
            }
            }
    }
    return $ReturnArray
}