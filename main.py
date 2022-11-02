import pandas as pd
from simulation.team import Team
from simulation.group import Group
from simulation.tournament import Tournament
from simulation.report import Report

NUMBER_OF_SIMULATIONS = 10000

def main():
    """Main function."""

    # Load data
    data = pd.read_csv("data/teams.csv")

    # Initialize a simulation report
    report = Report(NUMBER_OF_SIMULATIONS)

    # Translate teams from csv to python objects
    worldcup = data.groupby(['group']).groups
    groups = []
    for key, value in worldcup.items():
        teams = []
        for i in value:
            team = Team(data.loc[i]["country"], data.loc[i]["fifa_code"], data.loc[i]["fifa_score"])
            teams.append(team)
            report.add_team(team)
        group = Group(key, teams)
        groups.append(group)

    for i in range(NUMBER_OF_SIMULATIONS):
        tournament = Tournament(groups)
        tournament.play_group_stage()
        tournament.initialize_knockout_stage(report)
        tournament.play_knockout_stage(report)
        tournament.get_winner(report)

    print()
    print(report.get_report())
    print()


if __name__ == "__main__":
    main()
