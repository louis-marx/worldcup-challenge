import pandas as pd
from simulation.team import Team
from simulation.group import Group
from simulation.tournament import Tournament


def main():
    """Main function."""

    groups = []
    data = pd.read_csv("data/wordlcup.csv")
    worldcup = data.groupby(['group']).groups
    for key, value in worldcup.items():
        teams = []
        for i in value:
            teams.append(Team(
                data.loc[i]["country"], data.loc[i]["fifa_code"], data.loc[i]["fifa_score"]))
        group = Group(key, teams)
        groups.append(group)

    tournament = Tournament(groups)
    tournament.play_group_stage()
    tournament.initialize_knockout_stage()
    tournament.play_knockout_stage()
    tournament.display_tournament()


if __name__ == "__main__":
    main()
