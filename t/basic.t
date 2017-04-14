use Test;
use lib 'lib';

use MinG;

plan 5;

sub fs(Str $s) {
    return feature_from_str($s);
}

##############
# FIRST TEST #
##############
ok "+V" eq feature_from_str("+V").to_str;

###############
# SECOND TEST #
###############
say MinG::Grammar.new(lex => ()).litem_tree.qtree();
ok "ROOT " eq MinG::Grammar.new(lex => ()).litem_tree.qtree();

##############
# THIRD TEST #
##############
my $fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));

my $g = MinG::Grammar.new(lex => ($fit));
my $q = $g.litem_tree.qtree();
say $q;
ok "[.ROOT  [.=A abc ] ] " eq $q;

###############
# FOURTH TEST #
###############
$fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));
my $sit = MinG::LItem.new(phon => "jas", sem => "", features => (fs("+A")));
my $tit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("+A")));

$g = MinG::Grammar.new(lex => ($fit, $sit, $tit));
my $t = $g.litem_tree;
$q = $t.qtree;
say $q;
ok "[.ROOT  [.=A abc ] [.+A jas abc ] ] " eq $q;

##############
# FIFTH TEST #
##############
$fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));
$sit = MinG::LItem.new(phon => "gogo", sem => "", features => (fs("+A"), fs("=B"), fs("C")));
$tit = MinG::LItem.new(phon => "gogo", sem => "", features => (fs("+A"), fs("=B"), fs("-C")));

$g = MinG::Grammar.new(lex => ($fit, $sit, $tit));
$q = $g.litem_tree.qtree();
say $q;
ok "[.ROOT  [.=A abc ] [.C [.=B [.+A gogo ] ] ] [.-C [.=B [.+A gogo ] ] ] ] " eq $q;

done-testing;
