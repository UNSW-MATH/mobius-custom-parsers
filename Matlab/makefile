# Try to detect cmaple
ifeq ($(origin CMAPLE), undefined)
    ifeq ($(shell uname -r | grep -i microsoft),)  # Not WSL
        CMAPLE := $(shell which maple)
    else
        CMAPLE := "/mnt/c/Program Files/Maple 2024/bin.X86_64_WINDOWS/cmaple.exe"
    endif
endif

ifeq ($(CMAPLE),)
$(error cmaple not found! Please install Maple or set CMAPLE manually)
endif


.PHONEY all: superclean unitTests
	$(CMAPLE) matlab_previewer.mpl
	
	for library in *.lib; do echo $$library ;make "$${library%.lib}".zip; done

.PHONY: unitTests
unitTests: unitTests/HTML_examples.html

unitTests/HTML_examples.html: unitTests/matlab_previewer_tests.mpl \
                              unitTests/unitTests.mpl
	cd unitTests && $(CMAPLE) matlab_previewer_tests.mpl


%.zip: %.ind %.lib
	zip "$*.zip" "$*.ind" "$*.lib"

superclean:
	rm -f *.ind *.lib *.zip

