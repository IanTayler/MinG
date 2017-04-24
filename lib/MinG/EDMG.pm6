use strict;
use MinG;

unit module MinG::EDMG;

#####################################################
#   EXTERNAL THINGS     #   SHOULD STAY CONSTANT    #
#####################################################
=begin pod
=head1 EXPORTED CLASSES AND FUNCTIONS
=end pod

#|{
    Class that defines an EDMG feature.
    }
class Feature is MinG::Feature {
    has Bool $.is_adj;
    has Bool $.is_head_mov;
    has Bool $.is_covert_mov;
}

#|{
    Class that defines an EDMG lexical item.
    }
class LItem is MinG::LItem { }; # As of now, I don't see any needed additions.

#|{
    Class that defines an EDMG grammar.
    }
class Grammar is MinG::Grammar { }; # No additions needed for now. 
