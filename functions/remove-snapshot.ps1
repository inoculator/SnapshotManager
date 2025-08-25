function remove-snapshot {
    <#
        .DESCRIPTION
            removes a snapshot by a given list of machines and a snapshot name
        .PARAMETER VirtualMachineList
            an array of virtual machine names (aka domains)
            if no machine name is given, all machines are target
        .PARAMETER SnapshotName
            a name of the snapshot to remove (can be a regular expression)
            if no snapshot is given, all snapshots are target
        .OUTPUTS
            an array of machine names, snapshots and removal status
            $returnvalue
                .VirtualMachineName = Domain
                .Snapshot = snapshotname
                .status = [removed || failed]
        
    #>
    [cmdletbinding()]
    param (
        [alias("vms")][array]$VirtualMachineNames = @($(sudo virsh list --all|select-object -skip 2).split([system.Environment]::NewLine,[StringSplitOptions]::removeEmptyEntries)|foreach-object { $_.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[1] }),
        [string]$SnapShotname = "RemoveAll"        
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
            $GetSnapshotResult = get-snapshot -VirtualMachineNames $vm.VirtualMachineName
            if ($GetSnapshotResult.SnapShotList.count -gt 0) {
                foreach ($Snapshot in $GetSnapshotResult.SnapShotList) {
                    if ($SnapShotname -eq "RemoveAll" -or $Snapshot.Name -match $SnapShotname) {
                        if ($Snapshot.status -eq "disk-snapshot") {
                            ## will not handle disk-only snaps
                            $Status = "Disk-only not removable!"

                        } else {
                            write-verbose "Sending delete request for $($Snapshot.Name) to $($vm.VirtualMachineName)"
                            $Status = @($(sudo virsh snapshot-delete $vm.VirtualMachineName --snapshotname $Snapshot.Name))
                        }
                        $ReturnArray += [PSCustomObject]@{
                            VirtualMachineName = $vm.VirtualMachineName
                            SnapshotName = $Snapshot.name
                            Status = $Status
                        }
                    }
                }
            }


        }
    }

    return $ReturnArray
}