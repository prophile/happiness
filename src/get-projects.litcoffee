Get Projects
============

When a team switch occurs, we need to bind to the list of projects
from that team.

    teamSrc = Happiness.Firebase.Child(Happiness.TeamList.CurrentTeam)
    teamData = Happiness.Firebase.Stream(teamSrc)
                                 .map((x) ->
                                   [x.name(),
                                    _.keys(x.val())])
                                 .skipDuplicates(_.isEqual)
    Happiness.ProjectSwitcher.NewProjectList.plug teamData

