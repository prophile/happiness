Site Initialisation
===================

Firstly, we put up a container for bits published by the various components.

    window.Happiness = {}

We defer all core initialisation until post-pageload.

    $ ->

Editor Setup
------------

The first thing we do as part of init is prepare the code window for editing.

      editor = ace.edit "editor"
      editor.setTheme "ace/theme/textmate"
      editor.getSession().setMode "ace/mode/python"

