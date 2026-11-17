# Repositorio APT local de Mytical.
#
# Dependencias (Ubuntu 26.04):
#   apt-utils  -> apt-ftparchive
#   gnupg      -> gpg y gpgv (firma y verificación)
#   dpkg       -> dpkg-deb
#   gzip, make
#
#   sudo apt install apt-utils gnupg dpkg gzip make
#
# Uso:
#   make -C distro packages          # genera los .deb en distro/build/
#   make -C distro/apt repo          # public/ sin firmar
#   make -C distro/apt sign GPG_KEY=<fingerprint|uid>
#   make -C distro/apt test
#   make -C distro/apt clean
#
# `sign` reconstruye el repo antes de firmar. No pide passphrase: usa
# `gpg --batch`, así que la clave debe estar sin passphrase (o ya desbloqueada
# por gpg-agent).

SHELL := /bin/bash

APT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
DISTRO_DIR := $(abspath $(APT_DIR)/..)
BUILD_DIR := $(DISTRO_DIR)/build
PUBLIC ?= $(APT_DIR)/public

CODENAME := mytical
COMPONENT := main
ARCH := amd64
DIST := $(PUBLIC)/dists/$(CODENAME)
BIN := $(DIST)/$(COMPONENT)/binary-$(ARCH)

GPG ?= gpg
# Obligatorio para `make sign`; nunca se guarda una clave privada en el repo.
GPG_KEY ?=

.PHONY: repo sign test clean

repo:
	@set -euo pipefail; \
	shopt -s nullglob; \
	debs=( "$(BUILD_DIR)"/*.deb ); \
	if [ $${#debs[@]} -eq 0 ]; then \
	  echo "ERROR: no hay .deb en $(BUILD_DIR)" >&2; \
	  echo "       ejecuta: make -C $(DISTRO_DIR) packages" >&2; \
	  exit 1; \
	fi; \
	if ! command -v apt-ftparchive >/dev/null 2>&1; then \
	  echo "ERROR: falta apt-ftparchive (Ubuntu: sudo apt install apt-utils)" >&2; \
	  exit 1; \
	fi; \
	rm -rf "$(PUBLIC)/pool" "$(DIST)"; \
	mkdir -p "$(BIN)"; \
	for deb in "$${debs[@]}"; do \
	  pkg="$$(dpkg-deb -f "$$deb" Package)"; \
	  src="$$(dpkg-deb -f "$$deb" Source || true)"; \
	  src="$${src%% (*}"; \
	  src="$${src:-$$pkg}"; \
	  dest="$(PUBLIC)/pool/$(COMPONENT)/$${src:0:1}/$$src"; \
	  mkdir -p "$$dest"; \
	  cp -p "$$deb" "$$dest/"; \
	done; \
	( cd "$(PUBLIC)" && apt-ftparchive packages pool > "$(BIN)/Packages" ); \
	gzip -9n -c "$(BIN)/Packages" > "$(BIN)/Packages.gz"; \
	printf '%s\n' \
	  'APT::FTPArchive::Release {' \
	  '  Origin "Mytical";' \
	  '  Label "Mytical";' \
	  '  Suite "$(CODENAME)";' \
	  '  Codename "$(CODENAME)";' \
	  '  Architectures "$(ARCH)";' \
	  '  Components "$(COMPONENT)";' \
	  '  Description "Repositorio APT local de Mytical";' \
	  '};' > "$(PUBLIC)/.apt-release.conf"; \
	( cd "$(PUBLIC)" && apt-ftparchive -c .apt-release.conf release "dists/$(CODENAME)" > .Release.new && mv .Release.new "dists/$(CODENAME)/Release" ); \
	echo "OK: repo en $(PUBLIC) ($${#debs[@]} paquete(s))"

sign: repo
	@set -euo pipefail; \
	if [ -z "$(GPG_KEY)" ]; then \
	  echo "ERROR: define GPG_KEY=<fingerprint|uid> de una clave sin passphrase" >&2; \
	  echo "       ejemplo: make sign GPG_KEY=apt@mytical.invalid" >&2; \
	  exit 1; \
	fi; \
	if ! command -v "$(GPG)" >/dev/null 2>&1; then \
	  echo "ERROR: falta $(GPG) (Ubuntu: sudo apt install gnupg)" >&2; \
	  exit 1; \
	fi; \
	"$(GPG)" --batch --yes --no-tty --local-user "$(GPG_KEY)" --digest-algo SHA256 \
	  --output "$(DIST)/Release.gpg" --detach-sign "$(DIST)/Release"; \
	"$(GPG)" --batch --yes --no-tty --local-user "$(GPG_KEY)" --digest-algo SHA256 \
	  --clearsign --output "$(DIST)/InRelease" "$(DIST)/Release"; \
	echo "OK: firmado $(DIST)/InRelease"

test:
	bash "$(DISTRO_DIR)/tests/test_apt_repo.sh"

clean:
	@set -euo pipefail; \
	if [ -z "$(PUBLIC)" ] || [ "$(PUBLIC)" = "/" ]; then \
	  echo "ERROR: PUBLIC no es un directorio seguro: '$(PUBLIC)'" >&2; \
	  exit 1; \
	fi; \
	rm -rf "$(PUBLIC)"; \
	echo "OK: limpio $(PUBLIC)"
