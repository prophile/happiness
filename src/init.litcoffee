Site Initialisation
===================

Firstly, we put up a container for bits published by the various components.

    window.Happiness = {}

We defer all core initialisation until post-pageload.

    $ ->
