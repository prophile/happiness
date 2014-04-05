Component: Project Switcher
===========================

The project switcher allows one to switch between projects of a
particular team.

    Happiness.ProjectSwitcher = {}

Project List Tracking
---------------------

The most important bit of model this component deals with is keeping
the list of projects associated with the current team. We do this
with a bus which can be pushed to for a new list associated with a
particular team (as a (team, list) pair).

    Happiness.ProjectSwitcher.NewProjectList = new Bacon.Bus()

The project list delta event stream is just that bus filtered to
active teams, plus "reset" type events from when the team list is
switched.

    resetEvent = Happiness.TeamList.CurrentTeam
                                   .toEventStream()
                                   .map(null)
    receiveEvent = Happiness.TeamList.CurrentTeam
                                     .sampledBy(Happiness.ProjectSwitcher.NewProjectList,
                                                (team, [listTeam, list]) ->
                                                  if listTeam is team then list else null)
                                     .filter((x) -> x?)
    listDelta = resetEvent.merge(receiveEvent)
    Happiness.ProjectSwitcher.CurrentProjects = listDelta.toProperty(null)

Project Selection
-----------------

We can switch between projects, triggered by various sources.

    switchProject = new Bacon.Bus()
    Happiness.ProjectSwitcher.CurrentProject = switchProject.toProperty(null)

This resets to null whenever we switch teams.

    switchProject.plug Happiness.TeamList.CurrentTeam.changes().map(null)

Projects Dropdown
-----------------

When we receive a new project list, we clear out the projects
dropdown and recreate it, assuming it's not null.

    Happiness.ProjectSwitcher.CurrentProjects
                             .filter((x) -> x?)
                             .onValue (projs) ->

All items in the dropdown have the class "proj-dropdown-element",
so we can just scourge them from the DOM.

      $('.proj-dropdown-element').remove()

It's then just a matter of inserting each element in turn.

      dropdown = $('#proj-list ul')
      for proj in projs
        link = $("<a href=\"#\">#{proj}</a>")
        switchProject.plug link.asEventStream('click').map(proj)
        item = $('<li class="proj-dropdown-element">')
        item.append link
        dropdown.prepend item

### Visibility

When we have no "projects list" (as opposed to an empty projects
list) we hide the projects dropdown entirely.

    Happiness.ProjectSwitcher.CurrentProjects
                             .map((x) -> not x?)
                             .assign $('#proj-list'), 'toggleClass', 'hidden'

### Caption

The title of the projects dropdown should be the currently selected
project, if one is selected.

    Happiness.ProjectSwitcher.CurrentProject
                             .map((x) -> x ? "Projects")
                             .assign($('#proj-name'), 'text')

New Projects
------------

Creating new projects is essentially just a matter of forcing a new
name into the projects list.

    handleSubmitEvent = (event) ->
      event.preventDefault()
      $('#new-project').blur()
    newProjectRequest = $('#new-project').asEventStream('submit', handleSubmitEvent)
    switchProject.plug Happiness.InputValues('#new-project input')
                                .sampledBy(newProjectRequest)

