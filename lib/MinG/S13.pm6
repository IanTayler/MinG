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
    Function used to compare two priorities. Uses Priority.bigger_than method internally.
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
    has Array[Mover] $.movers;
    has Node $.node;

    method bigger_than(QueueItem $other) {
        return self.priority.bigger_than($other.priority);
    }
}

class Queue {
    has QueueItem @.items;
}

#####################################################
#   EXTERNAL THINGS     #   SHOULD STAY CONSTANT    #
#####################################################
=begin pod
=head1 EXPORTED CLASSES AND FUNCTIONS
=end pod
