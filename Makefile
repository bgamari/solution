all : hi.js

%.js : %.coffee
	coffee -b -c $<
