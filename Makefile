SHELL := /bin/bash
PFU ?= $(HOME)/janam_fota/a11/XT3/91.57_20251001.PFU
FW  ?= out/fota/partitions
DTB ?= out/fota/boot/dtb/from-boot.dtb

.PHONY: help bootstrap inventory extract dtb panel hw firmware fetch kernel rootfs image flash release test clean

help:
	@echo "make bootstrap   - installera verktyg"
	@echo "make inventory   - adb-inventering av enheten"
	@echo "make extract     - packa upp PFU (PFU=...)"
	@echo "make dtb         - boot/dtbo -> dtb"
	@echo "make panel       - generera paneldrivrutin ur $(DTB)"
	@echo "make hw          - sammanstall hardvara ur $(DTB)"
	@echo "make firmware    - plocka firmware ur $(FW)"
	@echo "make fetch       - hamta mainline-karna"
	@echo "make kernel      - bygg karna + dtb"
	@echo "make rootfs      - bygg Ubuntu Touch rootfs"
	@echo "make image       - packa boot.img"
	@echo "make flash       - skriv till enheten (kraver --yes manuellt)"
	@echo "make release     - bygg installationsbar zip (out/xt3-ut-*.zip)"
	@echo "make test        - sjalvtest av alla DT-verktyg"

bootstrap:
	./scripts/00-bootstrap.sh

inventory:
	./scripts/01-device-inventory.sh

extract:
	./scripts/02-extract-fota.sh "$(PFU)"

dtb:
	./scripts/04-unpack-boot.sh out/fota/partitions/boot.img out/fota/boot
	./scripts/04-unpack-boot.sh out/fota/partitions/dtbo.img out/fota/dtbo

panel:
	./scripts/05-gen-panel.sh $(DTB)

hw:
	./scripts/14-hw-from-dtb.py --dtb $(DTB)

firmware:
	./scripts/11-collect-firmware.sh --from-dir $(FW)
	./scripts/16-fetch-upstream-firmware.sh

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

test:
	./tests/selftest.sh

clean:
	rm -rf out/kbuild out/kernel out/boot.img
