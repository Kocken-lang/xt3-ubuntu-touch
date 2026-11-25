1795573083052244447
Bus 001 Device 015: ID 18d1:d00d Google Inc. Xiaomi Mi/Redmi 2 (fastboot)
=== edl-hjalp:
Capstone library is missing (optional).
Keystone library is missing (optional).
Usage:
    edl.py -h | --help
    edl.py [--vid=vid] [--pid=pid] [--portname=portname] [--serial]
    edl.py [--loader=filename] [--memory=memtype] [--portname=portname] [--serial]
    edl.py [--debugmode] [--portname=portname] [--serial]
    edl.py [--gpt-num-part-entries=number] [--gpt-part-entry-size=number] [--gpt-part-entry-start-lba=number] [--portname=portname] [--serial]
    edl.py [--memory=memtype] [--skipstorageinit] [--maxpayload=bytes] [--sectorsize==bytes] [--pagesperblock=number] [--portname=portname] [--serial]
    edl.py server [--tcpport=portnumber] [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py memorydump [--partitions=partnames] [--debugmode] [--vid=vid] [--pid=pid] [--portname=portname] [--serial] [--serial_number=serial_number]
    edl.py printgpt [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--loader=filename] [--debugmode]  [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py gpt <directory> [--memory=memtype] [--lun=lun] [--genxml] [--loader=filename]  [--skipresponse] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--pagesperblock=number] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py r <partitionname> <filename> [--memory=memtype] [--sectorsize==bytes] [--pagesperblock=number] [--lun=lun] [--loader=filename]  [--skipresponse] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py rl <directory> [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--skip=partnames] [--genxml]  [--skipresponse] [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py rf <filename> [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--loader=filename] [--debugmode]  [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py rs <start_sector> <sectors> <filename> [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--memory=memtype] [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py w <partitionname> <filename> [--partitionfilename=filename] [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--skipwrite] [--skipresponse] [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--devicemodel=value] [--skipstorageinit] [--portname=portname] [--serial]
