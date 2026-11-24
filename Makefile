SHELL := /bin/bash
PFU ?= $(HOME)/janam_fota/a11/XT3/91.57_20251001.PFU
DTB ?= $(firstword $(wildcard out/stock/*.dtb out/boot/dtb/*.dtb))

.PHONY: help bootstrap inventory extract dtb panel fetch kernel rootfs image flash release clean

help:
	@echo "make bootstrap   - installera verktyg"
	@echo "make inventory   - adb-inventering av enheten"
	@echo "make extract     - packa upp PFU (PFU=...)"
	@echo "make dtb         - boot/dtbo -> dtb"
	@echo "make panel       - generera paneldrivrutin"
	@echo "make fetch       - hamta mainline-karna"
	@echo "make kernel      - bygg karna + dtb"
	@echo "make rootfs      - bygg Ubuntu Touch rootfs"
	@echo "make image       - packa boot.img"
	@echo "make flash       - skriv till enheten (kraver --yes manuellt)"
	@echo "make release     - bygg installationsbar zip (out/xt3-ut-*.zip)"

bootstrap:
	./scripts/00-bootstrap.sh

inventory:
	./scripts/01-device-inventory.sh

extract:
	./scripts/02-extract-fota.sh "$(PFU)"

dtb:
	./scripts/04-unpack-boot.sh out/stock/boot.img
	-[ -f out/stock/dtbo.img ] && ./scripts/04-unpack-boot.sh out/stock/dtbo.img

panel:
	./scripts/05-gen-panel.sh $(DTB)

fetch:
	./scripts/06-fetch-mainline.sh

kernel:
	./scripts/07-build-kernel.sh

rootfs:
	./scripts/08-build-rootfs.sh

image:
	./scripts/09-pack-boot.sh

flash:
	./scripts/10-flash.sh --yes

release:
	./scripts/12-make-release.sh

clean:
	rm -rf out/kbuild out/kernel out/boot.img
