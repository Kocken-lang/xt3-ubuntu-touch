1795652196354221110
ldr	x0, =0x84000009
	smc	#0
	bl	record_mmu_state
	bl	preserve_boot_args

	adrp	x1, early_init_stack
	mov	sp, x1
	mov	x29, xzr
	adrp	x0, __pi_init_idmap_pg_dir
	mov	x1, xzr
	bl	__pi_create_init_idmap

	/*
	 * If the page tables have been populated with non-cacheable
	 * accesses (MMU disabled), invalidate those tables again to
	 * remove any speculatively loaded cache lines.
	 */
	cbnz	x19, 0f
	dmb     sy
	mov	x1, x0				// end of used region
	adrp    x0, __pi_init_idmap_pg_dir
	adr_l	x2, dcache_inval_poc
	blr	x2
	b	1f

	/*
	 * If we entered with the MMU and caches on, clean the ID mapped part
	 * of the primary boot code to the PoC so we can safely execute it with
	 * the MMU off.
	 */
0:	adrp	x0, __idmap_text_start
	adr_l	x1, __idmap_text_end
	adr_l	x2, dcache_clean_poc
	blr	x2

1:	mov	x0, x19
	bl	init_kernel_el			// w0=cpu_boot_mode
	mov	x20, x0

	/*
	 * The following calls CPU setup code, see arch/arm64/mm/proc.S for
	 * details.
	 * On return, the CPU will be ready for the MMU to be turned on and
	 * the TCR will have been set.
	 */
	bl	__cpu_setup			// initialise processor
	b	__primary_switch
SYM_CODE_END(primary_entry)

	__INIT
SYM_CODE_START_LOCAL(record_mmu_state)
	mrs	x19, CurrentEL
	cmp	x19, #CurrentEL_EL2
	mrs	x19, sctlr_el1
	b.ne	0f
=== record_mmu_state:
