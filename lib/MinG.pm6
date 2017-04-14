use strict;
=begin pod
=head1 NAME

MinG -- A small module for working with Stabler's Minimalist Grammars in Perl6.
=end pod

enum FWay <MERGE MOVE>;
enum FPol <PLUS MINUS>;

#|{
    A class that defines an MG-style-feature.

    FWay $.way marks whether it is to be deleted through Merge or through Move.

    FPol $.pol marks the polarity of the feature (selector/licensor or selectee/licensee).

    Str $.type is the category of the feature (traditionally D, N, V, P, etc).
    }
class MinG::Feature {
    has FWay $.way;
    has FPol $.pol;
    has Str $.type;
}

#|{
    Takes a string description of a feature (e.g. "=D") and returns a MinG::Feature.
}
sub feature_from_str (Str $inp) of MinG::Feature {
    if $inp ~~ /^ <[= + \-]> \w+ / {
        my $fchar = ~$/.substr(0, 1);
        given $fchar {
            when '+' {
                return MinG::Feature.new(way =>  MOVE, pol => PLUS, type => ~$/.substr(1));
            }
            when '-' {
                return MinG::Feature.new(way =>  MOVE, pol => MINUS, type => ~$/.substr(1));
            }
            when '=' {
                return MinG::Feature.new(way =>  MERGE, pol => PLUS, type => ~$/.substr(1));
            }
        }
    } elsif $inp ~~ /^ \w+/ {
        return MinG::Feature.new(way =>  MERGE, pol => MINUS, type => ~$/);
    }
    die "$inp is not a valid description of a feature";
}

#|{
    A class that defines an MG-style Lexical Item as an array of features plus some phonetic and semantic content described currently as strings.
    }
class MinG::LItem {
    has MinG::Feature @.features;
    has Str $.sem;
    has Str $.phon;
}

#|{
    A class that defines a Grammar as an array of lexical items.
    }
class MinG::Grammar {
    has MinG::LItem @.lex;
}

=begin pod

=head1 CURRENTLY
=item Has classes that correctly describe MGs (MinG::Grammar), MG-LIs (MinG::LItem) and MG-style-features (MinG::Feature).
=item Has a subroutine (feature_from_str) that takes a string description of a feature (e.g. "=D") and returns a MinG::Feature.

=head1 TODO
=item Create lexical trees for Stabler's (2013) parsing method.
=item Make a parser for the MGs described.
=item Automatically generate LaTeX/qtree code for derivation trees.
=item Allow some useful expansions of MGs.

=head1 MAYDO
=item1  Create a probabilistic trainer.
=item2      Use annotated corpora to build lexical entries.
=item2      Use a small subset of predefined lexical entries and a non-annotated corpus to "guess" the feature specification of unknown lexical items.

=item1 Create a Montague-style semantics for MG trees.
=item1 Create a world-model for a knowledgable AI using such semantics.

=head1 AUTHOR
Ian G Tayler, C<< <iangtayler@gmail.com> >>
=head1 COPYRIGHT AND LICENSE
Copyright © 2017, Ian G Tayler <iangtayler@gmail.com>. All rights reserved.
This program is free software; you can redistribute it and/or modify
it under the Artistic License 2.0.

=end pod
