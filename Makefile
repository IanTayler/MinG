.PHONY: test
LIB=./lib/
test: t/basic.t
	PERL6LIB=$(LIB) perl6 t/basic.t
