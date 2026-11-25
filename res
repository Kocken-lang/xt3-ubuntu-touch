1795647982656961531
	adrp	x1, early_init_stack
	adrp	x2, __pi_init_idmap_pg_dir
	bl	__enable_mmu

	adrp	x1, early_init_stack
ldrx0, =0x84000009
	smc#0
	mov	sp, x1
	mov	x29, xzr
	mov	x0, x20				// pass the full boot status
