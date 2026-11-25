1795647947327812684
82:	 *  x20        primary_entry() .. __primary_switch()    CPU boot mode
134:	b	__primary_switch
224:SYM_FUNC_START_LOCAL(__primary_switched)
252:SYM_FUNC_END(__primary_switched)
380:	bl	__enable_mmu
382:	br	x8
463:SYM_FUNC_START(__enable_mmu)
477:SYM_FUNC_END(__enable_mmu)
512:SYM_FUNC_START_LOCAL(__primary_switch)
515:	bl	__enable_mmu
