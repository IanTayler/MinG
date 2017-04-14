NAME
====

MinG -- A small module for working with Stabler's Minimalist Grammars in Perl6.

CURRENTLY
=========

  * Has classes that correctly describe MGs (MinG::Grammar), MG-LIs (MinG::LItem) and MG-style-features (MinG::Feature).

  * Has a subroutine (feature_from_str) that takes a string description of a feature (e.g. "=D") and returns a MinG::Feature.

  * Has lexical trees for Stabler's (2013) parsing method.

  * Automatically generates LaTeX/qtree code for trees.

TODO
====

  * Make a parser for the MGs described.

  * Allow some useful expansions of MGs.

  * Make the parser more efficient by adding probabilistic rule-following.

MAYDO
=====

  * Create a probabilistic trainer.

  * Use annotated corpora to build lexical entries.

  * Use a small subset of predefined lexical entries and a non-annotated corpus to "guess" the feature specification of unknown lexical items.

  * Create a Montague-style semantics for MG trees.

  * Create a world-model for a knowledgable AI using such semantics.

AUTHOR
======

Ian G Tayler, `<iangtayler@gmail.com> `

COPYRIGHT AND LICENSE
=====================

Copyright © 2017, Ian G Tayler <iangtayler@gmail.com>. All rights reserved. This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
