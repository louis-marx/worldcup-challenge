import time
from simulation.utils import *
from simulation.match import Match
from simulation.knockout import Knockout

STAGES = ['Round of 16', 'Quarter finals', 'Semi finals', 'Final', 'World Champion']

class Tournament:
    """Soccer tournament"""

    def __init__(self, groups):
        """Initialize a soccer tournament"""
        self.groups = groups
        self.knockouts = []

    def play_group_stage(self):
        """Simulate the group stage results"""
        for group in self.groups:
            group.play_games()
        return None

    def get_groups_winners(self):
        """Retrieve all groups winners"""
        winners = []
        for group in self.groups:
            winners.append(group.get_winners())
        return winners

    def initialize_knockout_stage(self, report):
        stage = STAGES[0]
        winners = self.get_groups_winners()
        games = []
        for i in range(0, len(winners), 2):
            games.append(Match(winners[i][1], winners[i+1][2]))
            report.update(stage, [winners[i][1], winners[i+1][2]])
            games.append(Match(winners[i][2], winners[i+1][1]))
            report.update(stage, [winners[i][2], winners[i+1][1]])
        self.knockouts.append(Knockout(stage, games))
        return None

    def get_next_knockout(self, report):
        stage = STAGES[len(self.knockouts)]
        self.knockouts[-1].play_games()
        winners = self.knockouts[-1].get_winners()
        games = []
        for i in range(0, len(winners), 2):
            games.append(Match(winners[i], winners[i+1]))
            report.update(stage, [winners[i], winners[i+1]])
        self.knockouts.append(Knockout(stage, games))
        return None

    def play_knockout_stage(self, report):
        while len(self.knockouts[-1].games) > 1:
            self.get_next_knockout(report)
        self.knockouts[-1].play_games()
        return None

    def get_winner(self, report):
        stage = STAGES[-1]
        winner = self.knockouts[-1].games[0].get_winner()
        report.update(stage, [winner])
        return winner

    @add_line_breaks
    def display_groups_headers(self):
        """Display groups names"""
        print(end='               ')
        for group in self.groups:
            print("GROUP " + group.id, end='           ')

    @add_line_breaks
    def display_groups_games(self):
        "Display all groups games"
        print("  GAMES :", end='   ')
        for i in range(len(self.groups[0].games)):
            for group in self.groups:
                group.games[i].display_results()
            line_breaks(1)
            time.sleep(.1)
            print(end='            ')
        return None

    @add_line_breaks
    def display_groups_points(self):
        """Display groups points results"""
        print("RESULTS :", end='   ')
        for i in range(len(self.groups[0].teams)):
            for group in self.groups:
                print(str(i+1) + " " + group.rank_teams()[i][0].fifa_code +
                      " (" + str(group.rank_teams()[i][1]) + " PTS)", end='     ')
            print()
            time.sleep(.1)
            print(end='            ')
        return None

    def display_group_stage(self):
        """Display group stage results with decorators"""
        self.display_groups_headers()
        display_separators(len(self.groups), "=")
        self.display_groups_games()
        display_separators(len(self.groups), "-")
        self.display_groups_points()
        return None

    def display_knockout_title(self, i):
        line_breaks(1)
        time.sleep(.1)
        print(end='            ')
        print(59*'=', end='   ')
        print(FINAL_STAGE[i], end='   ')
        print(59*'=')
        time.sleep(.1)
        return None

    def display_knockout_stage(self):
        for i in range(len(self.knockouts)):
            self.display_knockout_title(i)
            self.knockouts[i].display_games()
            time.sleep(.1)
        return None

    @add_line_breaks
    def display_tournament(self):
        self.display_group_stage()
        self.display_knockout_stage()
        return None
