1795648042656390169
^Iadrp^Ix2, __pi_init_idmap_pg_dir
^Ibl^I__enable_mmu
^Ildr^Ix0, =0x84000009
^Ismc^I#0

^Iadrp^Ix1, early_init_stack
^Imov^Isp, x1
^Imov^Ix29, xzr
^Imov^Ix0, x20^I^I^I^I// pass the full boot status
^Imov^Ix1, x21^I^I^I^I// pass the FDT
^Ibl^I__pi_early_map_kernel^I^I// Map and relocate the kernel
