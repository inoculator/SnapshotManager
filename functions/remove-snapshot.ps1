function remove-snapshot {
    <#
        .DESCRIPTION
            removes a snapshot by a given list of machines and a snapshot name
        .PARAMETER VirtualMachineList
            alias: vms
            A SearchPattern to filter machines
            if empty all machines will be returned
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
        [ValidateNotNullOrWhiteSpace()][alias("vms")][array]$VirtualMachineNames = ".*",
        [string]$SnapShotname = "RemoveAll"        
    )

    ## filter requested
    $VMList = get-virtualmachine -SearchPattern $VirtualMachineNames

    $ReturnArray = @()
    if ($VMList.count -gt 0 ) {
        foreach ( $vm in $VMList) {
            write-verbose "REMOVE-SNAPSHOT: Processing $($vm.VirtualMachineName)"
            $GetSnapshotResult = get-snapshot -VirtualMachineNames $vm.VirtualMachineName
            if ($GetSnapshotResult.SnapShotList.count -gt 0) {
                foreach ($Snapshot in $GetSnapshotResult.SnapShotList) {
                    if ($SnapShotname -eq "RemoveAll" -or $Snapshot.Name -match $SnapShotname) {
                        if ($Snapshot.status -eq "disk-snapshot") {
                            ## will not handle disk-only snaps
                            $Status = "Disk-only not removable!"

                        } else {
                            write-verbose "REMOVE-SNAPSHOT: Sending delete request for $($Snapshot.Name) to $($vm.VirtualMachineName)"
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