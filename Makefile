.PHONY: test doc md
LIB=./lib/
test: t/basic.t
	perl6 t/basic.t
	perl6 xt/basic.t

doc: lib/MinG.pm6
	perl6 --doc=HTML lib/MinG.pm6 > doc/MinG.html
	PERL6LIB=$(LIB) perl6 --doc=HTML lib/MinG/S13.pm6 > doc/S13.html

md: lib/MinG.pm6
	perl6 --doc=Markdown doc/README.pod6 > README.md
