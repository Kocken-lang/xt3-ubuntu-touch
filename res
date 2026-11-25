1795645461256108814
=== makefile targets:
2:spotless:
19:make-make:
36:LK_TOP_DIR:= .
90:all:: $(OUTBIN) $(OUTELF).lst $(OUTELF).debug.lst $(OUTELF).sym $(OUTELF).size $(OUTELF_STRIP) APPSBOOTHEADER
211:all:: $(EXTRA_BUILDDEPS)
230:MEMRWOFF:= .
268:clean: $(EXTRA_CLEANDEPS)
271:install: all
275:configheader:
306:.PHONY: configheader
=== project-lista:
aboot-surf7k.mk aboot-surf8k.mk apq8064.mk apq8084.mk armemu-test.mk beagle-test.mk fsm9010.mk fsm9900.mk lk1st-apq8084.mk lk1st-mdm9607.mk lk1st-mdm9640.mk lk1st-msm8226.mk lk1st-msm8610.mk lk1st-msm8660.mk lk1st-msm8909.mk lk1st-msm8916.mk lk1st-msm8952.mk lk1st-msm8953.mk lk1st-msm8960.mk lk1st-msm8974.mk lk1st-msm8994.mk lk1st-msm8996.mk lk2nd-apq8084.mk lk2nd-mdm9607.mk lk2nd-mdm9640.mk lk2nd-msm8226.mk lk2nd-msm8610.mk lk2nd-msm8660.mk lk2nd-msm8909.mk lk2nd-msm8916.mk lk2nd-msm8952.mk lk2nd-msm8953.mk lk2nd-msm8960.mk lk2nd-msm8974.mk lk2nd-msm8994.mk lk2nd-msm8996.mk mdm9607.mk mdm9615.mk mdm9615_nandwrite.mk mdm9625.mk mdm9635.mk mdm9640.mk msm7627_6x.mk msm7627_6x_nandwrite.mk msm7627_surf.mk msm7627_surf_nandwrite.mk msm7627a.mk msm7627a_nandwrite.mk msm7630_fusion.mk msm7630_fusion_nandwrite.mk msm7630_surf.mk msm7630_surf_nandwrite.mk msm8226.mk msm8610.mk msm8660.mk msm8660_surf.mk msm8909.mk msm8916.mk msm8952.mk msm8953.mk msm8960.mk msm8974.mk msm8994.mk msm8996.mk osk5912-test.mk pc-x86-test.mk qemu-arm-test.mk qsd8250_ffa.mk qsd8250_ffa_nandwrite.mk qsd8250_surf.mk qsd8250_surf_nandwrite.mk qsd8650a_st1x.mk qsd8650a_st1x_nandwrite.mk sam7ex256-test.mk surf-test.mk 
=== filer i target/msm8953:
include
init.c
mdtp_defs.c
meminfo.c
oem_panel.c
regulator.c
rules.mk
target_display.c
tools
