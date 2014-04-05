Component: Editor
=================

The editor is the core part of the IDE.

    Happiness.Editor = {}

Firepad
-------

The path for the firepad is a combination of the module name, project
and team.

    combinePath = (team, proj, module) ->
      return null unless team?
      return null unless proj?
      return null unless module?
      "#{team}/#{proj}/#{module}"
    path = Bacon.combineWith(combinePath,
                             Happiness.TeamList.CurrentTeam,
                             Happiness.ProjectSwitcher.CurrentProject,
                             Happiness.ModuleList.CurrentModule)
    base = Happiness.Firebase.Child(path)

The pad needs switching whenever the base changes. For the sake of
convenience, we do this with a nasty chunk of imperative code.

    lastPad = null
    base.onValue (newSource) ->
      if lastPad?
        lastPad.dispose()
        lastPad = null
        $('#editor-container').empty()
      if newSource?
        edit = $('<div id="editor">')
        $('#editor-container').append(edit)
        _.defer ->
          ew = ace.edit "editor"
          ew.setTheme "ace/theme/textmate"
          ew.getSession().setMode "ace/mode/python"
          lastPad = Firepad.fromACE newSource,
                                    ew,
                                    userId: AUTH_DATA['username']
          _.defer ->
            $('.powered-by-firepad').remove()

