from random import *


class Match:
    """Soccer match"""

    def __init__(self, team_a, team_b):
        """Initialize a soccer team"""
        self.team_a = team_a
        self.team_b = team_b

    def get_results(self):
        score = [randint(0, 4), randint(0, 4)]
        return score

    def display_results(self):
        score = self.get_results(self)
        results = self.team_a.country + " " + \
            score[0] + " | " + score[1] + " " + self.team_a.country
        return results
