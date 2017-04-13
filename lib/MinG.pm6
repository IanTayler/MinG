use strict;

unit module MinG;

enum FWay <MERGE MOVE>;
enum FPol <PLUS MINUS>;

class MinG::Feature {
    has FWay $.way;
    has FPol $.pol;
    has Str $.type;
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

class MinG::LItem {
    has MinG::Feature @.features;
    has Str $.sem;
    has Str $.phon;
}
class MinG::Grammar {
    has MinG::LItem @.lex;
}
