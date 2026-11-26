1795652587468089416
rc=0
make[1]: Leaving directory '/home/moon/xt3/out/kbuild'
make[1]: Leaving directory '/home/moon/xt3/out/kbuild'
12M Nov 26 01:23
--- markor efter cpu_setup:
ffff80008002e288:	35ffffa7 	cbnz	w7, ffff80008002e27c <vec_probe_vqs+0xa4>
ffff80008002e28c:	35fffca2 	cbnz	w2, ffff80008002e220 <vec_probe_vqs+0x48>
ffff80008002e290:	17fffff5 	b	ffff80008002e264 <vec_probe_vqs+0x8c>
ffff80008002e294:	d53812c0 	mrs	x0, smcr_el1
ffff80008002e298:	927cec00 	and	x0, x0, #0xfffffffffffffff0
ffff80008002e29c:	aa010000 	orr	x0, x0, x1
ffff80008002e2a0:	d51812c0 	msr	smcr_el1, x0
ffff80008002e2a4:	04bf5820 	rdsvl	x0, #1
ffff80008002e2a8:	53047c00 	lsr	w0, w0, #4
ffff80008002e2ac:	6b02001f 	cmp	w0, w2
--
ffff80008002f4e0:	b2680000 	orr	x0, x0, #0x1000000
ffff80008002f4e4:	d5181040 	msr	cpacr_el1, x0
ffff80008002f4e8:	d5033fdf 	isb
ffff80008002f4ec:	d51812df 	msr	smcr_el1, xzr
ffff80008002f4f0:	d5381000 	mrs	x0, sctlr_el1
ffff80008002f4f4:	b2440000 	orr	x0, x0, #0x1000000000000000
ffff80008002f4f8:	d5181000 	msr	sctlr_el1, x0
--
ffff80008002f510 <cpu_enable_sme2>:
