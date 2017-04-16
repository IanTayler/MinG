.PHONY: test doc md s13
LIB=./lib/
test: t/basic.t
	perl6 t/basic.t
	perl6 xt/basic.t

doc: lib/MinG.pm6 lib/MinG/S13.pm6
	perl6 --doc=HTML lib/MinG.pm6 > doc/MinG.html
	PERL6LIB=$(LIB) perl6 --doc=HTML lib/MinG/S13.pm6 > doc/S13.html

md: lib/MinG.pm6
	perl6 --doc=Markdown doc/README.pod6 > README.md

s13: lib/MinG.pm6 lib/MinG/S13.pm6
	PERL6LIB=$(LIB) perl6 lib/MinG/S13.pm6
