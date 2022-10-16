from numpy import random


class Match:
    """Soccer match"""

    def __init__(self, team_a, team_b, score=[]):
        """Initialize a soccer game"""
        self.team_a = team_a
        self.team_b = team_b
        self.score = score

    def play_game(self):
        score = [random.poisson((2*self.team_a.fifa_score-self.team_b.fifa_score)/self.team_b.fifa_score),
                 random.poisson((2*self.team_b.fifa_score-self.team_a.fifa_score)/self.team_a.fifa_score)]
        self.score = score
        return None

    def display_results(self):
        results = self.team_a.fifa_code + " " + \
            str(self.score[0]) + " - " + str(self.score[1]) + \
            " " + self.team_b.fifa_code
        return results
