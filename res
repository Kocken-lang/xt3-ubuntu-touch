1795648617368916782
ffff8000817f15f0 <__primary_switch>:
ffff8000817f15f0:	d503245f 	bti	c
ffff8000817f15f4:	f0000001 	adrp	x1, ffff8000817f4000 <reserved_pg_dir>
ffff8000817f15f8:	f00006e2 	adrp	x2, ffff8000818d0000 <__initdata_begin>
ffff8000817f15fc:	97ffffe1 	bl	ffff8000817f1580 <__enable_mmu>
ffff8000817f1600:	58000180 	ldr	x0, ffff8000817f1630 <__primary_switch+0x40>
ffff8000817f1604:	d4000003 	smc	#0x0
ffff8000817f1608:	b00029c1 	adrp	x1, ffff800081d2a000 <early_init_stack>
ffff8000817f160c:	9100003f 	mov	sp, x1
ffff8000817f1610:	aa1f03fd 	mov	x29, xzr
