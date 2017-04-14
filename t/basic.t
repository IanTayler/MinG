use Test;
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
ok say MinG::Grammar.new(lex => ()).litem_tree.qtree();

##############
# THIRD TEST #
##############
my $fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));

my $g = MinG::Grammar.new(lex => ($fit));
ok say $g.litem_tree.qtree();

###############
# FOURTH TEST #
###############
$fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));
my $sit = MinG::LItem.new(phon => "jas", sem => "", features => (fs("+A")));
my $tit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("+A")));

$g = MinG::Grammar.new(lex => ($fit, $sit, $tit));
my $t = $g.litem_tree;
my $q = $t.qtree;
ok say $q;

##############
# FIFTH TEST #
##############
$fit = MinG::LItem.new(phon => "abc", sem => "", features => (fs("=A")));
$sit = MinG::LItem.new(phon => "gogo", sem => "", features => (fs("+A"), fs("=B"), fs("C")));
$tit = MinG::LItem.new(phon => "gogo", sem => "", features => (fs("+A"), fs("=B"), fs("-C")));

$g = MinG::Grammar.new(lex => ($fit, $sit, $tit));
ok say $g.litem_tree.qtree();

done-testing;
