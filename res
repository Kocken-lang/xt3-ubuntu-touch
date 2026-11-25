1795632165862402498
########## 1. BOOT.IMG (AOSP unpack_bootimg)
Traceback (most recent call last):
  File "/home/moon/xt3/tools/unpack_bootimg.py", line 563, in <module>
    main()
    ~~~~^^
  File "/home/moon/xt3/tools/unpack_bootimg.py", line 558, in main
    info = unpack_bootimg(args.boot_img, args.out)
  File "/home/moon/xt3/tools/unpack_bootimg.py", line 484, in unpack_bootimg
    info = unpack_boot_image(image_file, output_dir)
  File "/home/moon/xt3/tools/unpack_bootimg.py", line 289, in unpack_boot_image
    extract_image(offset, size, boot_img, os.path.join(output_dir, name))
    ~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/moon/xt3/tools/unpack_bootimg.py", line 41, in extract_image
    with open(extracted_image_name, 'wb') as file_out:
         ~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^
IsADirectoryError: [Errno 21] Is a directory: 'out/kernel'

########## 2. DTBO (AOSP mkdtboimg dump)
dt_table_header:
               magic = d7b7ab1e
          total_size = 499382
         header_size = 32
       dt_entry_size = 32
      dt_entry_count = 12
   dt_entries_offset = 32
           page_size = 4096
             version = 0
dt_table_entry[0]:
             dt_size = 42542
           dt_offset = 416
                  id = 00000000
                 rev = 00000000
           custom[0] = 00000000
           custom[1] = 00000000
           custom[2] = 00000000
           custom[3] = 00000000

########## 3. VBMETA (AOSP avbtool info)
Algorithm:                SHA256_RSA4096
Rollback Index:           0
Flags:                    0
Rollback Index Location:  0
Descriptors:
      Flags:                 1
      Flags:                 2
      Image Size:            23879680 bytes
      Hash Algorithm:        sha256
      Partition Name:        boot
      Salt:                  526009602f9cbf24e42eddcfe1a75d6fc68934d4da72292fd50fad8acdadd922
      Digest:                ee72b696fca5c262f40a07b133060e58c6647e1181cfe461af1bea046d7e76f8
      Flags:                 0
      Image Size:            499382 bytes
      Hash Algorithm:        sha256
      Partition Name:        dtbo
      Salt:                  5a843f8255b605193335fe47b225748e3abc9d82856d37a3bdbc337a7c2821b0
      Digest:                a784851c185731e3a98b87781e077586ae85a7b432fd6f9c36424e761d63c7b2
      Flags:                 0
      Image Size:            3170316288 bytes
      Hash Algorithm:        sha1
      Partition Name:        system
      Salt:                  607587335d0a59df3c821a4194771e4844012136810d0b2f00c4471b0ecfeb28
      Root Digest:           da1354b7fa8b6d6b7cc473a395723f2bc0c6a775
      Flags:                 0
      Image Size:            825540608 bytes
      Hash Algorithm:        sha1
      Partition Name:        vendor
      Salt:                  607587335d0a59df3c821a4194771e4844012136810d0b2f00c4471b0ecfeb28
      Root Digest:           2ce78ad8d8c1188faf4d1525f6fdf98198bb8e71
      Flags:                 0
