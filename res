1795638274812984213
17:ERROR: modpost: "crypto_unregister_alg" [arch/arm64/crypto/sm4-ce-cipher.ko] undefined!
18:ERROR: modpost: "kernel_neon_begin" [arch/arm64/crypto/sm4-ce-cipher.ko] undefined!
19:ERROR: modpost: "cpu_have_feature" [arch/arm64/crypto/sm4-ce-cipher.ko] undefined!
20:ERROR: modpost: "crypto_register_alg" [arch/arm64/crypto/sm4-ce-cipher.ko] undefined!
21:ERROR: modpost: "__stack_chk_fail" [arch/arm64/crypto/sm4-ce-cipher.ko] undefined!
22:ERROR: modpost: "kernel_neon_end" [arch/arm64/crypto/sm4-ce-cipher.ko] undefined!
23:ERROR: modpost: "alt_cb_patch_nops" [arch/arm64/crypto/sm4-ce-cipher.ko] undefined!
24:ERROR: modpost: "kernel_neon_begin" [arch/arm64/crypto/aes-neon-blk.ko] undefined!
25:ERROR: modpost: "neon_aes_cbc_cts_decrypt" [arch/arm64/crypto/aes-neon-blk.ko] undefined!
26:ERROR: modpost: "neon_aes_cbc_cts_encrypt" [arch/arm64/crypto/aes-neon-blk.ko] undefined!
28:make[3]: *** [/home/moon/xt3/out/src/linux/scripts/Makefile.modpost:147: Module.symvers] Error 1
29:make[2]: *** [/home/moon/xt3/out/src/linux/Makefile:2137: modpost] Error 2
30:make[1]: *** [/home/moon/xt3/out/src/linux/Makefile:248: __sub-make] Error 2
32:make: *** [Makefile:248: __sub-make] Error 2
