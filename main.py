import collections
from scipy.stats import poisson
import pandas as pd
from simulation.team import Team
from simulation.group import Group
from simulation.tournament import Tournament
from simulation.report import Report

NUMBER_OF_SIMULATIONS = 100000


def main():
    """Main function."""

    # Load data
    data = pd.read_csv("data-raw/worldcup_teams.csv")
    xgoal = pd.read_csv("data/xgoal.csv", index_col=0)

    # Initialize a simulation report
    report = Report(NUMBER_OF_SIMULATIONS)

    most_probable_outcomes = xgoal
    for i in range(xgoal.shape[0]):
        for j in range(xgoal.shape[1]):
            score = 0
            proba = 0
            for k in range(5):
                if poisson.pmf(k, xgoal.iloc[i, j]) > proba:
                    score = k
                    proba = poisson.pmf(k, xgoal.iloc[i, j])
            most_probable_outcomes.iloc[i, j] = score
    
    print()
    print(most_probable_outcomes)
    print()

    most_probable_outcomes.to_csv('outputs/most_probable_outcomes.csv')

    # Translate teams from csv to python objects
    worldcup = data.groupby(['group']).groups
    groups = []
    for key, value in worldcup.items():
        teams = []
        for i in value:
            team = Team(data.loc[i]["team"], data.loc[i]
                        ["team_fifa_code"])
            teams.append(team)
            report.add_team(team)
        group = Group(key, teams)
        groups.append(group)

    tournament = Tournament(groups)
    tournament.play_group_stage(most_probable_outcomes, False)
    tournament.display_group_stage()
    tournament.initialize_knockout_stage(report)
    tournament.play_knockout_stage(most_probable_outcomes, False, report)
    tournament.display_knockout_stage()





    # tournament = Tournament(groups)
    # for i in range(NUMBER_OF_SIMULATIONS):
    #     tournament.play_group_stage(xgoal)
    #     tournament.initialize_knockout_stage(report)
    #     tournament.play_knockout_stage(xgoal, report)
    #     tournament.get_winner(report)
    #     tournament.reset()

    # print()
    # print(report.get_report())
    # print()

    # report.get_report().to_csv('outputs/simulation_report.csv')

    # group_proba = {}
    # for group in groups:
    #     group_proba[group.id] = []
    #     for i in range(NUMBER_OF_SIMULATIONS):
    #         group.play_games(xgoal)
    #         # outcome = ' '.join([team[0].team for team in group.rank_teams()])
    #         outcome = group.get_winners(
    #         )[1].team + '/' + group.get_winners()[2].team
    #         group_proba[group.id].append(outcome)
    #         group.reset()
    #         # print(outcome)

    # group_stage = pd.DataFrame(
    #     columns=['Group', 'First', 'Second', 'Likelihood'])
    # for key, value in group_proba.items():
    #     counter = collections.Counter(value)
    #     result = [key] + counter.most_common(1)[0][0].split(
    #         '/') + [100*counter.most_common(1)[0][1]/NUMBER_OF_SIMULATIONS]
    #     group_stage = pd.concat([group_stage, pd.Series(
    #         result, index=group_stage.columns).to_frame().T])

    # print()
    # print(group_stage)
    # print()

    # group_stage.to_csv('outputs/most_probable_group_outcomes.csv', index=False)




if __name__ == "__main__":
    main()
