all : solution.js

%.js : %.coffee
	coffee -b -c $<
