1795643723199415656
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
CONFIG_PSTORE_RAM=y
=== edl minneslasning:
    edl.py [--loader=filename] [--memory=memtype] [--portname=portname] [--serial]
    edl.py [--gpt-num-part-entries=number] [--gpt-part-entry-size=number] [--gpt-part-entry-start-lba=number] [--portname=portname] [--serial]
    edl.py [--memory=memtype] [--skipstorageinit] [--maxpayload=bytes] [--sectorsize==bytes] [--pagesperblock=number] [--portname=portname] [--serial]
    edl.py memorydump [--partitions=partnames] [--debugmode] [--vid=vid] [--pid=pid] [--portname=portname] [--serial] [--serial_number=serial_number]
    edl.py printgpt [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--loader=filename] [--debugmode]  [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py gpt <directory> [--memory=memtype] [--lun=lun] [--genxml] [--loader=filename]  [--skipresponse] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--pagesperblock=number] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py r <partitionname> <filename> [--memory=memtype] [--sectorsize==bytes] [--pagesperblock=number] [--lun=lun] [--loader=filename]  [--skipresponse] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py rl <directory> [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--skip=partnames] [--genxml]  [--skipresponse] [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
