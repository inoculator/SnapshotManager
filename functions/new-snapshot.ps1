function new-snapshot {
    <#
    .Description
        Creates a Snapshot for a each given virtual machine
    .Parameter VirtualMachineNames (Alias vms)
        Mandatory
        an array of machine names
    .PARAMETER SnapshotName
        a string value containgin a name for the snapshot
        if empty a generic name is generated
    .OUTPUTS
        an array of given Machines with the status of the operation
    .NOTES
        The given list of machines is validated against existing machines.
        
    #>

    param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][alias("vms")][array]$VirtualMachineNames,
        [string]$SnapShotname = $("Generic-$(get-date -format "yyyy-MMM-dd-hhmm")")
    )


}