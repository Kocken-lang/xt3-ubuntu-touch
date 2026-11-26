1795652508546039812

ifdef CONFIG_ARCH_WANTS_PRE_LINK_VMLINUX
vmlinux.unstripped: arch/$(SRCARCH)/tools/vmlinux.arch.o

arch/$(SRCARCH)/tools/vmlinux.arch.o: vmlinux.o FORCE
	$(Q)$(MAKE) $(build)=arch/$(SRCARCH)/tools $@
endif

ARCH_POSTLINK := $(wildcard $(srctree)/arch/$(SRCARCH)/Makefile.postlink)

# Final link of vmlinux with optional arch pass after final link
cmd_link_vmlinux =							\
	$< "$(LD)" "$(KBUILD_LDFLAGS)" "$(LDFLAGS_vmlinux)" "$@";	\
	$(if $(ARCH_POSTLINK), $(MAKE) -f $(ARCH_POSTLINK) $@, true)

targets += vmlinux.unstripped .vmlinux.export.o
vmlinux.unstripped: scripts/link-vmlinux.sh vmlinux.o .vmlinux.export.o $(KBUILD_LDS) FORCE
	+$(call if_changed_dep,link_vmlinux)
ifdef CONFIG_DEBUG_INFO_BTF
vmlinux.unstripped: $(RESOLVE_BTFIDS) $(srctree)/scripts/gen-btf.sh
endif

ifdef CONFIG_BUILDTIME_TABLE_SORT
vmlinux.unstripped: scripts/sorttable
endif
