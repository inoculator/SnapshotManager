function new-snapshot {
    <#
    .Description
        Creates a Snapshot for a each given virtual machine
    .Parameter VirtualMachineNames
            alias: vms
            A SearchPattern to filter machines
            if empty all machines will be addressed
    .PARAMETER SnapshotName
        a string value containing a name for the snapshot
        if empty a generic name is generated
    .PARAMETER clean [switch]
        if true all previous snapshots will be removed first
    .OUTPUTS
        an array of given Machines with the status of the operation
    .NOTES
        The given list of machines is validated against existing machines.

        DOES NOT WORK ON MACHINES HAVING RAW DISKS (in progress)
        
    #>

    [cmdletbinding()]
    param (
        [ValidateNotNullOrWhiteSpace()][Alias("vms")][string]$VirtualMachineNames = ".*",
        [ValidateNotNullOrWhiteSpace()][string]$SnapShotname = $("Generic-$(get-date -format "yyyy-MMM-dd-hhmm")"),
        [switch]$clean
    )

    ## filter requested
    $VMList = get-virtualmachine -SearchPattern $VirtualMachineNames
    
    $ReturnArray = @()
    if ($VMList.count -gt 0 ) {
        foreach ( $vm in $VMList) {
            write-verbose "Processing $($vm.VirtualMachineName)"

            ## copy snapshot name to internal loop process
            $thisSnapShotName = $SnapShotname
            
            ## enumerate machine disks
            $DiskArray= @()
            $DiskList = @()
            $DiskList = @($(sudo virsh domblklist $vm.VirtualMachineName|select-object -skip 2).split([system.Environment]::NewLine,[StringSplitOptions]::removeEmptyEntries))
            foreach ($item in $DiskList) {
                $DiskArray += [PSCustomObject]@{
                    Target = $item.split(" ",[StringSplitOptions]::removeEmptyEntries)[0]
                    Source = $item.split(" ",[StringSplitOptions]::removeEmptyEntries)[1]
                    qcow2 = $item.split(" ",[StringSplitOptions]::removeEmptyEntries)[1] -match "\.qcow2$"
                }
            }

            if ( $DiskArray.qcow2 -contains $false ) {
                $Status = "WARNING: $($vm.VirtualMachineName) has none QCOW2 disks. not processing!"
                $thisSnapShotName = "N/A"

            } else {
                if ($clean) {
                    ## removing previous snapshots
                    ## the function returns a compatible array
                    write-verbose "NEW-SNAPSHOT: Start cleaning old snapshots on $($vm.VirtualMachineName)"
                    $ReturnArray += remove-snapshot -VirtualMachineNames $vm.VirtualMachineName
                    write-verbose "NEW-SNAPSHOT: Finished cleaning old snapshots on $($vm.VirtualMachineName)"
                }
                ## Create new Snapshot for machine
                write-verbose "NEW-SNAPSHOT: Sending request to create new Snapshot '$SnapShotname' on $($vm.VirtualMachineName)"
                $Status = @($(sudo virsh snapshot-create-as $vm.VirtualMachineName --name $SnapShotname --description "Created By Jenkins Job ${ENV:BUILD_NUMBER}" ))
            }
            $ReturnArray += [PSCustomObject]@{
                VirtualMachineName = $vm.VirtualMachineName
                Snapshotname = $thisSnapShotName
                Status = $Status
            }
        }
    }
    return $ReturnArray
}