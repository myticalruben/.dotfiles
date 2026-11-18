PACKAGES := mytical-sddm-theme mytical-session mytical-welcome mytical-desktop
BUILD := build

.PHONY: packages test clean
packages: $(PACKAGES:%=package-%)

package-%:
	mkdir -p $(BUILD)
	dpkg-deb --build --root-owner-group debian/$* $(BUILD)/$*_$(shell sed -n 's/^Version: //p' debian/$*/DEBIAN/control)_all.deb

test:
	@if command -v dpkg-deb >/dev/null 2>&1; then \
		$(MAKE) packages && \
		bash tests/test_packages.sh && \
		bash tests/test_session.sh; \
	else \
		echo "SKIP: dpkg-deb no disponible; se omiten test_packages.sh y test_session.sh"; \
	fi

clean:
	rm -rf $(BUILD)
