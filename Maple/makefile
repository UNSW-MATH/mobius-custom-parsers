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

.PHONY all: superclean
	$(CMAPLE) MaplePreviewCode.mpl > /dev/null
	$(CMAPLE) TestingThePreviewer.mpl > /dev/null
	
	for library in *.lib; do echo $$library ;make "$${library%.lib}".zip; done

%.zip: %.ind %.lib
	zip "$*.zip" "$*.ind" "$*.lib"

superclean:
	rm -f *.ind *.lib *.zip

