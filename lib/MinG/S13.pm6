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
            return Nil;
        }
        my $highest = @.items[0];
        my $index = 0;
        loop (my $i = 1; $i < @.items.elems; i++) {
            next if @.items[$i] eqv (QueueItem);
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
class DerivTree is Node {};

#|{
    Class that represents one derivation.
    }
class Derivation {
    has Str @input;
    has Queue $q;
    # $structure holds the current derivation tree of the derivation.
    has DerivTree $structure;

    #|{
        Method that returns whether this derivation still needs more steps.
        }
    method still_going() of Bool {
        return @input.elems > 0 and $q.elems > 0;
    }

    #|{ See Stabler (2013)}
    method merge1() of Derivation {
        
    }

    #|{ See Stabler (2013)}
    method merge2() of Derivation {

    }

    #|{ See Stabler (2013)}
    method merge3() of Derivation {

    }

    #|{ See Stabler (2013)}
    method merge4() of Derivation {

    }

    #|{ See Stabler (2013)}
    method move1() of Derivation {

    }

    #|{ See Stabler (2013)}
    method move2() of Derivation {

    }

    #|{
        Method that gets the expansions to be had in the next step.
        }
}

#####################################################
#   EXTERNAL THINGS     #   SHOULD STAY CONSTANT    #
#####################################################
=begin pod
=head1 EXPORTED CLASSES AND FUNCTIONS
=end pod

#|{
    Class that implements the parser per se. This is where all the magic happens.
    }
class MinG::S13 {
    has Derivation @!devq;
    # Trees of successful derivations!
    has DerivTree @results;

    #|{
        Method that runs one iteration of the parsing loop, running one step of each derivation in parallel. Gets all possible derivations.
        }
    method parallel_run() {
        # Notice we're using Promises.
        my @promises;
        for @!devq -> $dev {
            if not($dev.still_going()) {
                push @results, $dev.structure;
            } else {
                push @promises, Promise.start({ $dev.exps() });
            }
        }
        my @newdevq;
        for @promises -> $prom {
            append @newdevq, $prom.result;
        }
        @!devq = @newdevq;
    }

    #|{
        Method that runs one iteration of the parsing loop, running one step of one derivation only. No parallel computation.
        }
    method procedural_run() of DerivTree {
        my $this_dev = @!devq.pop();
        append @!devq, $this_dev.exps();
        return $this_dev.structure;
    }

    #|{
        Method that runs the main parsing loop using parallel_run. Gets all possible derivations.
        }
    method parallel_parse() of Bool {
        while @!devq.elems > 0 {
            self.parallel_run();
        }
        if @results.elems == 0 {
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
}
