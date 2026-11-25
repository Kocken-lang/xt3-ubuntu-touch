1795565226247210013
    edl.py [--loader=filename] [--memory=memtype] [--portname=portname] [--serial]
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
    edl.py wl <directory> [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--skip=partnames] [--skipresponse] [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--devicemodel=value] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py wf <filename> [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--loader=filename] [--skipresponse] [--debugmode] [--vid=vid] [--pid=pid] [--devicemodel=value] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py ws <start_sector> <filename> [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--skipwrite] [--skipresponse] [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--devicemodel=value] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py e <partitionname> [--memory=memtype] [--skipwrite] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--devicemodel=value] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py es <start_sector> <sectors> [--memory=memtype] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--skipwrite] [--loader=filename] [--skipresponse] [--debugmode] [--vid=vid] [--pid=pid] [--devicemodel=value] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py ep <partitionname> <sectors> [--memory=memtype] [--skipwrite] [--lun=lun] [--sectorsize==bytes] [--pagesperblock=number] [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--devicemodel=value] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py footer <filename> [--memory=memtype] [--lun=lun] [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py peek <offset> <length> <filename> [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--portname=portname] [--serial]
    edl.py peekdword <offset> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py peekqword <offset> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py memtbl <filename> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py poke <offset> <filename> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py pokehex <offset> <data> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py pokedword <offset> <data> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py pokeqword <offset> <data> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py secureboot [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py pbl <filename> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py qfp <filename> [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]
    edl.py getstorageinfo [--loader=filename] [--memory=memtype] [--pagesperblock=number] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py setbootablestoragedrive <lun> [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py getactiveslot [--memory=memtype] [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py setactiveslot <slot> [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py send <command> [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py xml <xmlfile> [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py rawxml <xmlstring> [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py nop [--loader=filename] [--debugmode] [--vid=vid] [--pid=pid] [--skipstorageinit] [--portname=portname] [--serial] [--devicemodel=value]
    edl.py modules <command> <options> [--memory=memtype] [--lun=lun] [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--devicemodel=value] [--portname=portname] [--serial]
    edl.py provision <xmlfile> [--loader=filename] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--portname=portname] [--serial]  [--devicemodel=value]
    edl.py qfil <rawprogram> <patch> <imagedir> [--loader=filename] [--memory=memtype] [--pagesperblock=number] [--debugmode] [--skipresponse] [--vid=vid] [--pid=pid] [--portname=portname] [--serial]  [--devicemodel=value]
    rs                          # Read sectors starting at start_sector to filename
    ws                          # Write filename to flash at start_sector
    es                          # Erase sectors at start_sector from flash
    ep                          # Erase sector count from flash partition
    peek                        # Dump memory at offset with given length to filename
    peekhex                     # Dump memory at offset and given length
    peekdword                   # Dump DWORD at memory offset
    peekqword                   # Dump QWORD at memory offset
    memtbl                      # Dump memory table to file
    poke                        # Write filename to memory at offset to memory
    pokehex                     # Write hex string data at offset to memory
    pokedword                   # Write DWORD to memory at offset
    pokeqword                   # Write QWORD to memory at offset
    memcpy                      # Copy memory from srcoffset with given size to dstoffset
    setbootablestoragedrive     # Change bootable storage drive to lun number
    --lun=lun                          Set lun to read/write from (UFS memory only)
    --sectorsize=bytes                 Set default sector size
    --memory=memtype                   Set memory type ("NAND", "eMMC", "UFS", "spinor")
    --partitions=partnames             Skip reading partition with names != "partname1,partname2,etc."
    --skipwrite                        Do not allow any writes to flash (simulate only)
    --skipresponse                     Do not expect a response from phone on read/write (some Qualcomms)
    --skipstorageinit                  Skip storage initialisation
    --gpt-part-entry-start-lba=number  Set GPT entry start lba sector [default: 0]
    --skip=partnames                   Skip reading partition with names "partname1,partname2,etc."
    --genxml                           Generate rawprogram[lun].xml
=== i koden:
96:                    np.sector = offset * self.parent.cfg.block_size // self.parent.cfg.SECTOR_SIZE_IN_BYTES
97:                    np.sectors = (length & 0xFFFF) * self.parent.cfg.block_size // self.parent.cfg.SECTOR_SIZE_IN_BYTES
104:                self.totalsectors = (self.parent.cfg.block_size // self.parent.cfg.SECTOR_SIZE_IN_BYTES) * \
123:            offset = partition.sector * self.parent.cfg.SECTOR_SIZE_IN_BYTES
124:            length = partition.sectors * self.parent.cfg.SECTOR_SIZE_IN_BYTES
173:        SECTOR_SIZE_IN_BYTES = 0
386:               f" SECTOR_SIZE_IN_BYTES=\"{self.cfg.SECTOR_SIZE_IN_BYTES}\"" + \
429:        <patch SECTOR_SIZE_IN_BYTES="512" byte_offset="16" filename="DISK" physical_partition_number="0"
