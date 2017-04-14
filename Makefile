.PHONY: test doc md
LIB=./lib/
test: t/basic.t
	PERL6LIB=$(LIB) perl6 t/basic.t

doc: lib/MinG.pm6
	perl6 --doc=HTML lib/MinG.pm6 > doc/MinG.html

md: lib/MinG.pm6
	perl6 --doc=Markdown lib/MinG.pm6 > README.md
