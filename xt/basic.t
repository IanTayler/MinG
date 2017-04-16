#!/usr/bin/env perl6
use lib 'lib';
use MinG;
use MinG::S13;
use Test;
use Test::META;

plan 4;

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

done-testing;
