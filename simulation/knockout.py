from simulation.match import Match
from simulation.utils import *


class Knockout:
    """Tournament knockout stage"""

    def __init__(self, stage, games):
        """Initialize a tournament knockout stage"""
        self.stage = stage
        self.games = games

    def play_games(self, xgoal):
        for match in self.games:
            match.play_game(xgoal)
        return None

    def get_winners(self):
        winners = []
        for match in self.games:
            winners.append(match.get_winner())
        return winners

    @add_line_breaks
    def display_games(self):
        n = len(self.games)
        print(end=12*' '+9*(8-n)*' ')
        for game in self.games:
            game.display_results()
        line_breaks(1)
        time.sleep(.1)
        return None
