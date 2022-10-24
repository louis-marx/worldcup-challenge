from random import randint
from numpy import random


class Match:
    """Soccer match"""

    def __init__(self, team_a, team_b):
        """Initialize a soccer game"""
        self.team_a = team_a
        self.team_b = team_b
        self.score = {team_a: 0, team_b: 0}

    def play_game(self):
        """Simulate the game result"""
        self.score[self.team_a] = random.poisson(
            (2*self.team_a.fifa_score-self.team_b.fifa_score)/self.team_b.fifa_score)
        self.score[self.team_b] = random.poisson(
            (2*self.team_b.fifa_score-self.team_a.fifa_score)/self.team_a.fifa_score)
        return None

# Could be further improved to simulate real penalties
    def get_winner(self):
        """Retrieve the game winner"""
        if self.score[self.team_a] > self.score[self.team_b]:
            winner = self.team_a
        elif self.score[self.team_a] < self.score[self.team_b]:
            winner = self.team_b
        else:
            winner = random.choice([self.team_a, self.team_b])
        return winner

    def display_results(self):
        """Display the game result"""
        print(self.team_a.fifa_code + " " + str(self.score[self.team_a]) + " - " + str(
            self.score[self.team_b]) + " " + self.team_b.fifa_code, end='     ')
        return None
