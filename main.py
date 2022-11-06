import pandas as pd
from simulation.team import Team
from simulation.group import Group
from simulation.tournament import Tournament
from simulation.report import Report

NUMBER_OF_SIMULATIONS = 100000


def main():
    """Main function."""

    # Load data
    data = pd.read_csv("data/teams.csv")
    xgoal = pd.read_csv("data/xgoal.csv", index_col=0)

    # Initialize a simulation report
    report = Report(NUMBER_OF_SIMULATIONS)

    # Translate teams from csv to python objects
    worldcup = data.groupby(['group']).groups
    groups = []
    for key, value in worldcup.items():
        teams = []
        for i in value:
            team = Team(data.loc[i]["team"], data.loc[i]
                        ["team_fifa_code"], data.loc[i]["team_total_fifa_points"])
            teams.append(team)
            report.add_team(team)
        group = Group(key, teams)
        groups.append(group)

    for i in range(NUMBER_OF_SIMULATIONS):
        tournament = Tournament(groups)
        tournament.play_group_stage(xgoal)
        tournament.initialize_knockout_stage(report)
        tournament.play_knockout_stage(xgoal, report)
        tournament.get_winner(report)

    print()
    print(report.get_report())
    print()


if __name__ == "__main__":
    main()
