use strict;
use MinG;
use MinG::S13;

#|{
    Grammar class that parses a file describing an MG lexicon.
    }
grammar MinG::From::Text::Grammar {
    token TOP {<header>\h*\n<lexlist>}

    rule header {\w* '=' <cat>}

    token cat {\w+}

    rule lexlist {<lex1=.lex>\h*\n<lexlist>|<lex2=.lex> }

    rule lex {<word> '::' <featlist>}

    token word {\w*}

    rule featlist {<feat1=.feat>\h+<featlist>|<feat2=.feat>}

    token feat {\+\w+|\-\w+|\=\w+|\w+}
}

#|{
    Class that creates a MinG::Grammar when used in conjunction with MinG::From::Text::Grammar
    }
class ConverterActions {

    method TOP ($/) {
        make MinG::Grammar.new( lex => $<lexlist>.made, start_cat => $<header>.made);
    }

    method header ($/) {
        make feature_from_str($<cat>.Str);
    }

    method lexlist ($/) {
        make $<lexlist> ?? append $<lexlist>.made, $<lex1>.made !! [$<lex2>.made];
    }

    method lex ($/) {
        make MinG::LItem.new( phon => $<word>.Str, features => $<featlist>.made);
    }

    method featlist ($/) {
        make $<featlist> ?? unshift $<featlist>.made, $<feat1>.made !! [$<feat2>.made];
    }

    method feat ($/) {
        make feature_from_str($/.Str);
    }

}

#|{
    Takes a string and returns the grammar that it describes.

    The format of an MG description is the following (comments are not actually allowed):

    START=C #(i.e. the start category)

    el :: =N D

    hombre :: N

    come :: =N V

    pan :: N

    :: =V =D I #this is an empty category

    no :: =V V

    :: =I C

    END

    }
sub grammar_from_text(Str $s) of MinG::Grammar is export {
    return MinG::From::Text::Grammar.parse($s, actions => ConverterActions).made;
}

grammar Do {
    token TOP { <header>' '*\n<lexlist> }

    rule header {\w+ '=' <cat>}
    rule cat {\w+}
    rule lexlist { <lex>' '*\n<lexlist> | <lex> }
    token lex {\w+}
}

sub MAIN() {
    parse_and_spit(grammar_from_text(Q:to<VERYEND>
        START=V
        comio       :: =D =D V
        el          :: =N D
        gran        :: =N N
        muchacho    :: N
        muchacha    :: N
        la          :: =N D
        Juan        :: D
        mermelada   :: N
        VERYEND
        ), "el gran muchacho comio la mermelada");
    parse_and_spit(grammar_from_text(Q:to<VERYEND>
        START=V
        comio :: =D =D V
        el :: =N D
        abada :: V
        muchacho :: N
        VERYEND
        ), "abada");
}
