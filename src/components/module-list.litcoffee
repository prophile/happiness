Component: Module List
======================

    Happiness.ModuleList = {}

The module list is displayed to the left of the editor, and contains
a list of modules contained within the current project.

This all comes from Firebase, and the first thing we do is grab the
current child.

    combinePath = (team, proj) ->
      return null unless team?
      return null unless proj?
      "#{team}/#{proj}"
    rootPath = Bacon.combineWith(combinePath,
                                 Happiness.TeamList.CurrentTeam,
                                 Happiness.ProjectSwitcher.CurrentProject)
    root = Happiness.Firebase.Child(rootPath)

Modules
-------

The list of current modules is a matter of streaming out the list
from Firebase. We do a quick check to make sure we're actually
looking at the current project too.

    eventChecker = (expectedPath, result) ->
      return null unless result.name() is expectedPath[1]
      return null unless result.ref().parent().name() is expectedPath[0]
      _.keys(result.val())

    modules = Bacon.combineAsArray(Happiness.TeamList.CurrentTeam,
                                   Happiness.ProjectSwitcher.CurrentProject)
                   .sampledBy(Happiness.Firebase.Stream(root),
                              eventChecker)
                   .skipDuplicates(_.isEqual)
                   .merge(rootPath.changes().map(null))
                   .map((x) -> if x?.length is 0 then ["robot"] else x)
                   .toProperty(null)
    Happiness.ModuleList.Modules = modules

Selected Module
---------------

The selected module can be changed by a number of factors.

    selectedModule = new Bacon.Bus()

Firstly, it gets reset when we change project: to null if there is no project,
otherwise to 'robot'.

    selectedModule.plug rootPath.map((x) -> if x? then "robot" else null)

    Happiness.ModuleList.CurrentModule = selectedModule.skipDuplicates()
                                                       .toProperty(null)

Module List
-----------

Whenever the module list gets updated, we re-create the selector.

    Happiness.ModuleList.Modules
                        .toEventStream()
                        .filter((x) -> x?)
                        .onValue (mods) ->

All modules have the mod-list-item class.

      $('.mod-list-item').remove()

      list = $('#mod-list')
      for mod in mods
        element = $('<a href="#">')
        element.text(mod)
        selectedModule.plug element.asEventStream('click')
                                   .map(mod)
        item = $('<li class="mod-list-item">')
        item.append element
        list.prepend item

New Modules
-----------

Creating new modules is essentially the same as creating projects.

    handleSubmitEvent = (event) ->
      event.preventDefault()
      $('#new-mod').blur()
    newModuleRequest = $('#new-mod').asEventStream('submit', handleSubmitEvent)
    selectedModule.plug Happiness.InputValues('#new-mod input')
                                 .sampledBy(newModuleRequest)

