Site Initialisation
===================

Firstly, we put up a container for bits published by the various components.

    window.Happiness = {}

We defer all core initialisation until post-pageload.

    $ ->

Editor Setup
------------

The first thing we do as part of init is prepare the code window for editing.

      Happiness.EditWindow = ace.edit "editor"
      Happiness.EditWindow.setTheme "ace/theme/textmate"
      Happiness.EditWindow.getSession().setMode "ace/mode/python"

Let's get rid of that obnoxious logo while we're at it.

      $('.powered-by-firepad').remove()

