use strict;
use MinG;

=begin pod
=head1 NAME

MinG::S13 -- Stabler's (2013) parser.
=end pod

#################################################
#   INTERNAL THINGS     #   MAY CHANGE RAPIDLY  #
#################################################
=begin pod
=head1 INTERNAL CLASSES AND FUNCTIONS]
=end pod
######################
# DEBUGGING   TOOLS  #
######################
#constant $DEBUG is export = 0;
#sub debug(Str $s) {
#    if $DEBUG {
#        say $s;
#    }
#}
#our $run_number is export = 1 if $DEBUG;

#############
# CONSTANTS #
#############
constant $IS_SELECTOR is export = -> Node $x { $x.feat_node and $x.label.way == MERGE and $x.label.pol == PLUS };
constant $IS_FEAT_NODE is export = -> Node $x { $x.feat_node };
constant $IS_NOT_FEAT  is export = -> Node $x { not ($x.feat_node) };

enum ParseWay < PROCEDURAL PARALLEL >;

#################################################################################
# Implemented the 'current' lexical tree as a global variable.
# This is the ugliest thing in the implementation. Should I at one point fix it?
# There's reasons for this global variable. Derivations need to have access to the
# lexical tree, but derivation objects are notoriously short-lived (they normally
# last a single step). So, having a lexical tree as an attribute of derivations means
# we'll copy it many times unnecessarily, given that the tree is the same for the whole
# parsing.
#
# Having this global variable is efficient and it's not very dangerous. While many
# things need to access it, only the parser ever changes it and it does it only
# once per parse. Taboos aside, I don't think this is so bad, just as long as this
# rule is followed:
#
########################################
# GLORIOUS RULE OF MAXIMUM IMPORTANCE: #
#**************************************************************
#* DO NOT UNDER ANY CIRCUMSTANCES CHANGE THE VALUE OF THIS    *
#*    VARIABLE FROM OUTSIDE THE MinG::S13::Parser CLASS.      *
#**************************************************************
our $s13_global_lexical_tree is export;
##########
#      ^ #
# THIS | #
##########

#|{
    Objects in this class describe positions in a Queue.
    }
class Priority {
    has Int @.pty;

    #|{
        A method that compares this object's priority with another Priority object's priority and returns true if this one's is smaller.
        }
    method bigger_than(Priority $other) of Bool {
        if self.length > $other.length {
            return False;
        } elsif $other.length > self.length {
            return True;
        } else {
            loop (my $i = 0; $i < self.length; $i++) {
                if @.pty[$i] > $other.pty[0] {
                    return False;
                } elsif @.pty[$i] < $other.pty[0] {
                    return True;
                }
            }
        }
        # If we got here, they both have the same priority.
        # I think this shouldn't happen, but I don't see why it would be a problem.
        # So, we're just throwing True in this case, and hope for the best.
        return True;
    }

    #|{
        Method that appends a number at the end of the priority. It returns a new Priority instead of changing itself automatically. Less efficient, but more useful for our purposes.
        }
    method add_p(Int $n) of Priority {
        my @new_pty = @.pty;
        @new_pty.push($n);
        return Priority.new(pty => @new_pty);
    }

    #|{
        Returns the length of the priority. In this implementation, priorities are sequences of numbers, and they are ordered lexicographically so that longer sequences have less priority than shorter ones.
        }
    method length() of Int {
        return @.pty.elems;
    }
}

#|{
    Function used to compare two priorities. Uses Priority.bigger_than method internally. There aren't many reasons to use it, but if you can find one, go ahead.
    }
sub bigger_pty (Priority $a, Priority $b) {
    return $a.bigger_than($b);
}

#|{
    Class for our movers: they represent the nodes we selected when we ran into a [MOVE, PLUS] feature and encountered a [MOVE, MINUS] feature as one of ROOT's children.
    }
class Mover {
    has Priority $.priority;
    has Node $.node;
}

#|{
    Objets of this class are items in a Queue. The only Queue we need to implement is the one for category predictions, so this is to be interpreted as an item in THAT queue.
    }
class QueueItem {
    has Priority $.priority;
    has Mover @.movers;
    has Node $.node;

    #|{
        This method is a wrapper around Priority.bigger_than so that it can be called more easily from a Queue object.
        }
    method bigger_than(QueueItem $other) {
        return self.priority.bigger_than($other.priority);
    }
}

#|{
    The Queue of category predictions.
    }
class Queue {
    has QueueItem @.items;

    #|{
        With this method, we find out the index of the highest-priority item. Linear time.
        }
    method ind_max() of Int {
        if @.items.elems == 0 {
            # It may or may not be better to die here. I'm letting it be for now.
            # Actually, nope. Dying here.
            die "Hey, this queue is empty!!!";
        }

        # The start may be empty without the whole thing being empty, so we need
        # to find the first non-empty place
        my uint16 $first_place = 0;
        # This is supposed to be safe because we already checked that the array
        # isn't empty. We may be in for a surprise in a few months, though.
        loop (; not(@.items[$first_place]); $first_place++){};
        my $highest = @.items[$first_place];

        my $index = $first_place;
        loop (my uint16 $i = $first_place; $i < @.items.elems; $i++) {
            next unless @.items[$i];
            if @.items[$i].bigger_than($highest) {
                $highest = @.items[$i];
                $index = $i;
            }
        }
        return $index;
    }

    #|{
        Method that gets a reference to the highest-priority item. Linear time.
        }
    method max() {
        return @.items[self.ind_max];
    }

    #|{
        Method that deletes the highest-priority item and returns it. Linear time.
        }
    method pop() {
        return @.items[self.ind_max]:delete;
    }

    #|{
        Method that adds an element to the Queue. This runs in constant time.
        }
    method push(QueueItem $new) {
        push @.items, $new;
    }

    #|{
        Method that gets the amount of elements in the Queue. It's not reliable because we keep deleted items in the @.items array. We get the right result when there's 0 elements because Perl6 deletes pseudo-deleted elements from the end of the array (even if they were pseudo-deleted a long time ago). Note: I guess this could easily break with future implementations of Perl6.
        }
    method elems() of Int {
        return @.items.elems;
    }
}

#|{
    Class that represents derivation trees. As of now, they're just Nodes.
    }
class DerivTree is Node {
    # This is all tentative. We don't really generate a derivation tree but a
    # weird and useless derivation chain. Consider it a placeholder for future
    # true derivations.
    method add_to_end(Node $n) {
        my $lastman = self;
        while $lastman.children.elems > 0 {
            $lastman = $lastman.children[0];
        }
        $lastman.children.push($n);
    }
};

#|{
    Class that represents one derivation.
    }
class Derivation {
    has Str @.input;
    has Queue $.q;
    # $structure holds the current derivation tree of the derivation.
    has DerivTree $.structure;

    #|{
        Method that returns whether this derivation still needs more steps.
        }
    method still_going() of Bool {
        return (@.input.elems > 0) || ($.q.elems > 0);
    }

    #|{ See Stabler (2013)}
    method scan(QueueItem $pred, Int $child_place) of Derivation {
        my $leave = $pred.node.children[$child_place];

        #debug("Scanned {$leave.label}");
        my $start_place = 1;
        $start_place = 0 if $leave.label eq "";

        my $struc = $.structure;
        $struc.add_to_end((DerivTree.new(label => "{$leave.label}",\
                                             children => ())));
        return Derivation.new(input => @.input[$start_place..*], q => $.q, structure => $struc);
    }

    #|{ See Stabler (2013)}
    # We pass most of the state around because we have to calculate all of this
    # anyway to check whether or not we need to to run the rule.
    method merge1(QueueItem $pred, Node @leaves, Node $selected, Node $selector) of Derivation {
        # The following is a bit of a mess. It closely follows the way the rule
        # was written in Stabler (2013), so if you're trying to understand this,
        # it may be a good idea to read that first.
        my $new_node = LexNode.new( label => $selector.label, children => @leaves);

        my $f_item = QueueItem.new(priority => $pred.priority.add_p(0),\
                                   movers => (),\
                                   node => $new_node);

        my $s_item = QueueItem.new(priority => $pred.priority.add_p(1),\
                                   movers => $pred.movers,\
                                   node => $selected);

        my $nq = $.q;
        $nq.push($f_item); $nq.push($s_item);
        my $struc = $.structure;
        $struc.add_to_end(DerivTree.new(label => "merge1({$selector.str_label}, {$selected.str_label})",\
                                             children => ()));

        return Derivation.new(input => @.input, q => $nq, structure => $struc);
    }

    #|{ See Stabler (2013)}
    method merge2(QueueItem $pred, Node @non_terms, Node $selected, Node $selector) of Derivation {
        my $new_node = LexNode.new( label => $selector.label, children => @non_terms);

        my $f_item = QueueItem.new(priority => $pred.priority.add_p(1),\
                                   movers => $pred.movers,\
                                   node => $new_node);

        my $s_item = QueueItem.new(priority => $pred.priority.add_p(0),\
                                   movers => (),\
                                   node => $selected);

        my $nq = $.q;
        $nq.push($f_item); $nq.push($s_item);

        my $struc = $.structure;
        $struc.add_to_end(DerivTree.new(label => "merge2({$selector.str_label}, {$selected.str_label})",\
                                             children => ()));

        return Derivation.new(input => @.input, q => $nq, structure => $struc);
    }

    #|{ See Stabler (2013)}
    method merge3(QueueItem $pred) of Derivation {

    }

    #|{ See Stabler (2013)}
    method merge4(QueueItem $pred) of Derivation {

    }

    #|{ See Stabler (2013)}
    method move1(QueueItem $pred) of Derivation {

    }

    #|{ See Stabler (2013)}
    method move2(QueueItem $pred) of Derivation {

    }

    #|{
        Method that gets the expansions to be had in the next step. Check the code's comments for more details.
        }
    method exps() of Array {
        my $this_prediction = $.q.pop();
        my @retv;
        return @retv unless $this_prediction;

        #debug("We got here. So prediction not empty.");

        # SCAN CONSIDERED. NEEDS MERGE1-4 and MOVE1-2.
        if $this_prediction.node.has_child(@.input[0]) -> $child_place {
            my $scanned = self.scan($this_prediction, $child_place);
            append @retv, $scanned if $scanned;
        } elsif $this_prediction.node.has_child("") -> $child_place {
            my $scanned = self.scan($this_prediction, $child_place);
            append @retv, $scanned if $scanned;
        }

        # Let's consider MERGE1 and MERGE2 first.
        # This line can be a bit daunting, but it's not that hard actually.
        # We grab this prediction's node and take the children of that node that
        # have the property of being a selector (i.e. FWAY::MERGE and FPol::PLUS).
        # If the list is empty, the condition evaluates to False. If it isn't,
        # it evaluates to True, and we get those children in the array called
        # @selector_ch.
        if $this_prediction.node.children_with_property($IS_SELECTOR) -> @selector_ch {
            # We iterate over every child that is a selector. Applying MERGE1
            # and/or MERGE2 if the conditions are met.
SEL_LOOP:   for @selector_ch -> $selector {
                # The following code checks that there is a node immediately below
                # ROOT that has the proper category.
                my $selected;
                my $selected_f = MinG::Feature.new(way => MERGE, pol => MINUS, type => $selector.label.type);
                my $selected_ind = $s13_global_lexical_tree.has_child($selected_f);
                $selected = $s13_global_lexical_tree.children[$selected_ind] if $selected_ind;

                # Get all leaves and do MERGE1
                if $selector.children_with_property($IS_NOT_FEAT) -> @leaves {
                    my $merged = self.merge1($this_prediction, @leaves, $selected, $selector);
                    append @retv, $merged if $merged;
                }
                # Get all non-leaves and do MERGE2
                if $selector.children_with_property($IS_FEAT_NODE) -> @non_terms {
                    my $merged = self.merge2($this_prediction, @non_terms, $selected, $selector);
                    append @retv, $merged if $merged;
                }
            }
        }
        return @retv;
    }
}

#####################################################
#   EXTERNAL THINGS     #   SHOULD STAY CONSTANT    #
#####################################################
=begin pod
=head1 EXPORTED CLASSES AND FUNCTIONS
=end pod

#|{
    Class that implements the parser per se. This is not where the magic happens, but it is where most of the external API is defined.
    }
class MinG::S13::Parser {
    has Derivation @!devq;
    # Trees of successful derivations!
    has DerivTree @.results;

    method devq() {
        return @!devq;
    }
    #|{
        Method that runs one iteration of the parsing loop, running one step of each derivation in parallel. Gets all possible derivations.
        }
    method parallel_run() {
        # Notice we're using Promises.
        #debug("Run number: $run_number");
        #debug("\tInitial \@!devq: ");
        #{ print "\t\t"; say @!devq; say "\n" } if $DEBUG;

        my @promises;
        for @!devq -> $dev {
            if not($dev.still_going()) {
                push @.results, $dev.structure;
            } else {
                push @promises, Promise.start({ $dev.exps() });
            }
        }
        my @newdevq;
        for @promises -> $prom {
            append @newdevq, $prom.result;
        }

        #debug("\tNew queue: ");
        #{ print "\t\t"; say @newdevq; say "\n" } if $DEBUG;
        @!devq = @newdevq;
        #$run_number++ if $DEBUG;
    }

    #|{
        Method that runs one iteration of the parsing loop, running one step of one derivation only. No parallel computation.
        }
    method procedural_run() of DerivTree {
        #debug("Run number: $run_number");
        #debug("\tInitial \@!devq: ");
        #{ print "\t\t"; say @!devq; say "\n" } if $DEBUG;
        my $this_dev = @!devq.pop();
        my @new_exps = $this_dev.exps();
        append @!devq, @new_exps if @new_exps; # Do not append if it is Nil.

        #debug("\tNew queue: ");
        #{ print "\t\t"; say @!devq; say "\n" } if $DEBUG;

        #$run_number++ if $DEBUG;
        return $this_dev.structure;
    }

    #|{
        Method that runs the main parsing loop using parallel_run. Gets all possible derivations.
        }
    method parallel_parse() of Bool {
        while @!devq.elems > 0 {
            self.parallel_run();
        }
        if @.results.elems == 0 {
            return False;
        } else {
            return True;
        }
    }

    #|{
        Method that runs the main parseing loop using procedural_run. Stops after it finds the first derivation.
        }
    method procedural_parse() of Bool {
        my $poss_result;
        while @!devq.elems > 0 and @!devq[@!devq.end].still_going {
            $poss_result = self.procedural_run();
        }
        if @!devq.elems == 0 {
            @!results.push($poss_result);
            return True;
        } else {
            return False;
        }
    }

    #|{
        Method that sets up a parser with a certain grammar and a certain input (taken as a string for convenience, converted to lower case and an array as needed) and creates the first derivation.
        }
    method setup(MinG::Grammar $g, Str $inp) {
        # Clean previous results:
        @.results = ();

        # Clean debugging symbols:
        #$run_number = 1 if $DEBUG;

        my @proper_input = $inp.lc.split(' ');

        # We set up the $s13_global_lexical_tree global variable. This should probably be
        # the only place where we do this.
        $s13_global_lexical_tree = $g.litem_tree();
        my $start_ind = $s13_global_lexical_tree.has_child($g.start_cat);

        die "bad start symbol for the grammar!" without $start_ind;

        my $start_categ = $s13_global_lexical_tree.children[$start_ind];

        my $que = Queue.new(items => (QueueItem.new(priority => Priority.new(pty => (0)),\
                                                    movers => (),\
                                                    node => $start_categ,\
                                                    )));
        my $start_dev = Derivation.new(input => @proper_input,\
                                       q => $que,\
                                       structure => DerivTree.new(label => "ROOT", children => ())\
                                       );
        push @!devq, $start_dev;
    }

    #|{
        Method to set the parser up, parse and spit the result. All in one go.
        }
    method parse_me(MinG::Grammar $g, Str $inp, ParseWay $do = PARALLEL) {
        say "Parsing $inp.";
        self.setup($g, $inp);
        #debug("\tThis is the input:\n\t\t{@.devq[0].input}\n\tLength:\n\t\t{@.devq[0].input.elems}");
        if $do == PROCEDURAL {
            if self.procedural_parse() {
                say "\t{@.results[0].qtree}";
            } else {
                say "\tThe string you passed is not in the language.";
            }
        } else {
            if self.parallel_parse() {
                for @.results -> $res {
                    say "\t{$res.qtree}";
                }
            } else {
                say "\tThe string you passed is not in the language.";
            }
        }

    }
}

#|{
    This is a wrapper subroutine to save to avoid using the MinG::S13::Parser class directly.
    }
sub parse_and_spit(MinG::Grammar $g, Str $inp, ParseWay $waytoparse = PARALLEL) is export {
    MinG::S13::Parser.new().parse_me($g, $inp, $waytoparse);
}

###############################
#            TEST             #
###############################
sub MAIN() {
    my $feat1 = feature_from_str("=A");
    my $feat2 = feature_from_str("A");
    my $startc = feature_from_str("B");

    my $item1 = MinG::LItem.new( features => ($feat1, $startc), phon => "b", sem => "");
    my $itema = MinG::LItem.new( features => ($feat2), phon => "a", sem => "");

    my $g = MinG::Grammar.new(lex => ($itema, $item1), start_cat => $startc);
    my $lexor = $g.litem_tree;
    say "{$lexor.qtree}\n";

    my $parser = MinG::S13::Parser.new();

    my @things = ["", "a", "b", "b a", "a b a", "abab"];

    for @things -> $thing {
        say "\n\tPROCEDURAL: ";
        $parser.parse_me($g, $thing, PROCEDURAL);

        say "\n\tPARALLEL: ";
        $parser.parse_me($g, $thing, PARALLEL);
    }

    my $c = feature_from_str("C"); my $selv = feature_from_str("=V"); my $v = feature_from_str("V"); my $d = feature_from_str("D"); my $seld = feature_from_str("=D");

    my $force = MinG::LItem.new( features => ($selv, $c), phon => ""); my $juan = MinG::LItem.new( features => ($d), phon => "juan"); my $come = MinG::LItem.new( features => ($seld, $seld, $v), phon => "come"); my $escupe = MinG::LItem.new( features => ($seld, $seld, $v), phon => "escupe"); my $pan = MinG::LItem.new( features => ($d), phon => "pan"); my $manteca = MinG::LItem.new( features => ($d), phon => "manteca");

    $g = MinG::Grammar.new(lex => ($juan, $come, $escupe, $pan, $manteca, $force), start_cat => $c);

    my @frases = ["Juan come pan", "manteca escupe Juan", "come escupe Juan", "Juan", "come", "Pan Come Manteca"];

    for @frases -> $frase {
        #say "\n\tPROCEDURAL: ";
        #$parser.parse_me($g, $frase, PROCEDURAL);

        say "\n\tPARALLEL: ";
        $parser.parse_me($g, $frase);
    }

}
