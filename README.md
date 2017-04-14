NAME
====

MinG -- A small module for working with Stabler's Minimalist Grammars in Perl6.

class MinG::Feature
-------------------

A class that defines an MG-style-feature. FWay $.way marks whether it is to be deleted through Merge or through Move. FPol $.pol marks the polarity of the feature (selector/licensor or selectee/licensee). Str $.type is the category of the feature (traditionally D, N, V, P, etc).

### sub feature_from_str

```
sub feature_from_str(
    Str $inp
) returns MinG::Feature
```

Takes a string description of a feature (e.g. "=D") and returns a MinG::Feature.

class MinG::LItem
-----------------

A class that defines an MG-style Lexical Item as an array of features plus some phonetic and semantic content described currently as strings.

class MinG::Grammar
-------------------

A class that defines a Grammar as an array of lexical items.

CURRENTLY
=========

  * Has classes that correctly describe MGs (MinG::Grammar), MG-LIs (MinG::LItem) and MG-style-features (MinG::Feature).

  * Has a subroutine (feature_from_str) that takes a string description of a feature (e.g. "=D") and returns a MinG::Feature.

TODO
====

  * Create lexical trees for Stabler's (2013) parsing method.

  * Make a parser for the MGs described.

  * Automatically generate LaTeX/qtree code for derivation trees.

  * Allow some useful expansions of MGs.

MAYDO
=====

  * Create a probabilistic trainer.

  * Use annotated corpora to build lexical entries.

  * Use a small subset of predefined lexical entries and a non-annotated corpus to "guess" the feature specification of unknown lexical items.

  * Create a Montague-style semantics for MG trees.

  * Create a world-model for a knowledgable AI using such semantics.

AUTHOR Ian G Tayler, `<iangtayler@gmail.com> `
==============================================

COPYRIGHT AND LICENSE Copyright © 2017, Ian G Tayler <iangtayler@gmail.com>. All rights reserved. This program is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
=========================================================================================================================================================================================================
