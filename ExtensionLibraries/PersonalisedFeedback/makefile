.PHONEY all: superclean
	maple PersonalisedFeedback.mpl 
	
	for library in *.lib; do echo $$library ;make "$${library%.lib}".zip; done

%.zip: %.ind %.lib 
	zip $*.zip $*.ind $*.lib

superclean:
	rm -f *.ind *.lib *.zip

