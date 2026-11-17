PACKAGES := mytical-session mytical-desktop
BUILD := build

.PHONY: packages test clean
packages: $(PACKAGES:%=package-%)

package-%:
	mkdir -p $(BUILD)
	dpkg-deb --build --root-owner-group debian/$* $(BUILD)/$*_$(shell sed -n 's/^Version: //p' debian/$*/DEBIAN/control)_all.deb

test: packages
	bash tests/test_packages.sh

clean:
	rm -rf $(BUILD)
