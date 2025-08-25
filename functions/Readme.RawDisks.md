we have one challenge that is about RAW disks.
automated snapshots do only work with QCOW2 disks. If a raw disk or a IMG disk is mounted to the system, the auto snapshot does not work anymore.
You can still run "--disk-only" snapshots, but those are not capable of automated removal in that manner.

====================================================================
    virsh snapshot-list PROD-DERSAPP007_Jenkins
        Name      Creation Time               State
        ------------------------------------------------------
        test123   2025-08-25 17:35:27 +0200   disk-snapshot
====================================================================

There is a very delight process to get a disk-only snapshot removed

====================================================================
--source: https://blog.phs.id.au/posts/2023-07-july/

    virsh # snapshot-delete 9 autosnap_1688973291_6869
    error: Failed to delete snapshot autosnap_1688973291_6869
    error: unsupported configuration: deletion of 1 external disk snapshots not supported yet

    virsh # blockcommit 9 /vm-disks/ssd/nms.autosnap_1688973291_6869 --active --wait --verbose --pivot
    Block commit: [100 %]
    Successfully pivoted

    virsh # snapshot-delete 9 --metadata autosnap_1688973291_6869
    Domain snapshot autosnap_1688973291_6869 deleted

    sudo rm /vm-disks/ssd/nms.autosnap_1688973291_6869
====================================================================

To create such a snapshot you can switch the "create-snapshot-as" option to "--disk-only" and exclude the none QCOW2 disks by adding a 
"--diskspec \[target\],snapshot=no", where "Target" is shown in the block list:

    virsh domblklist PROD-DERSAPP004_Nextcloud
        Target   Source
    --------------------------------------------------------------------
    vda      /var/vmdisks/PROD-DERSAPP004-disk001.qcow2
    vdb      /dev/disk/by-id/ata-SAMSUNG_HD204UI_S2HGJ9EB904597-part1

Reverting from such a snapshot looks like this

    [ T B D ] 



