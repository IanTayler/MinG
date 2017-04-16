#!/usr/bin/env perl6
use lib 'lib';
use MinG;
use MinG::S13;
use Test;
use Test::META;

plan 5;

meta-ok();

my $p1 = Priority.new(pty => (0, 0, 0));
my $p2 = Priority.new(pty => (1, 0, 0));
my $p3 = Priority.new(pty => (0, 1, 0));
my $p4 = Priority.new(pty => (1, 1));

ok ($p4.bigger_than($p1)) && ($p1.bigger_than($p3)) && ($p3.bigger_than($p2));

my $deriv = Derivation.new(input => ("sanga", "changa", "wanga"));
say $deriv.input;
ok $deriv.input.elems == 3;
ok $deriv.still_going;

############
# BIG TEST #
############
#my $feat1 = feature_from_str("=A");
#my $feat2 = feature_from_str("A");
#my $startc = feature_from_str("B");
#
#my $item1 = MinG::LItem.new( features => ($feat1, $startc), phon => "b", sem => "");
#my $itema = MinG::LItem.new( features => ($feat2), phon => "a", sem => "");
#
#my $g = MinG::Grammar.new(lex => ($itema, $item1), start_cat => $startc);
#my $lexor = $g.litem_tree;
#say $lexor.qtree;
#
#my $parser = MinG::S13::Parser.new();
#$parser.setup($g, "b a");
#
#ok $parser.procedural_parse();

ok True;

done-testing;
