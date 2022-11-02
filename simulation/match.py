from random import randint
from numpy import random


class Match:
    """Soccer match"""

    def __init__(self, team, opponent):
        """Initialize a soccer game"""
        self.team = team
        self.opponent = opponent
        self.score = {team: 0, opponent: 0}

    # To be further improved with modelling results
    def play_game(self):
        """Simulate the game result"""
        self.score[self.team] = random.poisson(
            (2*self.team.fifa_score-self.opponent.fifa_score)/self.opponent.fifa_score)
        self.score[self.opponent] = random.poisson(
            (2*self.opponent.fifa_score-self.team.fifa_score)/self.team.fifa_score)
        return None

    # Could be further improved to simulate real penalties
    def get_winner(self):
        """Retrieve the game winner"""
        if self.score[self.team] > self.score[self.opponent]:
            winner = self.team
        elif self.score[self.team] < self.score[self.opponent]:
            winner = self.opponent
        else:
            winner = random.choice([self.team, self.opponent])
        return winner

    def display_results(self):
        """Display the game result"""
        print(self.team.fifa_code + " " + str(self.score[self.team]) + " - " + str(
            self.score[self.opponent]) + " " + self.opponent.fifa_code, end='     ')
        return None
