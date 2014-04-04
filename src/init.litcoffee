Site Initialisation
===================

We defer all initialisation until post-pageload.

    $ ->

Editor Setup
------------

The first thing we do as part of init is prepare the code window for editing.

      editor = ace.edit "editor"
      editor.setTheme "ace/theme/textmate"
      editor.getSession().setMode "ace/mode/python"

