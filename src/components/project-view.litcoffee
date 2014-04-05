Component: Project View
=======================

The project view is the container that contains all the project
view elements.

We hide it when there's no current project.

    Happiness.ProjectSwitcher.CurrentProject
                             .map((x) -> not x?)
                             .assign $('#project-view'),
                                     'toggleClass',
                                     'hidden'

