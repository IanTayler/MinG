use MinG;
use MinG::S13;
use MinG::S13::Logic; # May not be necessary. Add it just in case, for forward-compatibility.
use MinG::From::Text;

sub MAIN(:$FILE, Bool :$eng0, Bool :$espa0) {
    my MinG::Grammar $g;
    if $espa0 {
        $g = grammar_from_file($ESPA0);
    } elsif $eng0 {
        $g = grammar_from_file($ENG0);
    } elsif $FILE {
        $g = grammar_from_file($FILE);
    } else {
        say "Run this script with option \"help\" to find out the proper usage";
        return 0;
    }
    my $p = MinG::S13::Parser.new();
    $p.init($g);
    say "LEXICON:";
    my @previous;
    for $g.lex -> $item {
        print $item.phon ~ "; " if $item.phon;
    }
    "".say;
    print "ENTRY>> ";
    for $*IN.lines() -> $line {
        my @sentences = $line.split(';');
        for @sentences -> $sentence {
            say $sentence.lc if @sentences.elems > 1;
            $p.large_parse($sentence.trim);
        }
        print "ENTRY>> ";
    }
}
