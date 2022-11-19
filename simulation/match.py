from numpy import random
import pandas as pd


class Match:
    """Soccer match"""

    xgoal = pd.read_csv("data/xgoal.csv", index_col=0)

    def __init__(self, team, opponent):
        """Initialize a soccer game"""
        self.team = team
        self.opponent = opponent
        self.score = {team: 0, opponent: 0}

    # To be further improved with modelling results
    def play_game(self, xgoal, rand):
        """Simulate the game result"""
        if rand:
            self.score[self.team] = random.poisson(
                xgoal.loc[self.team.team, self.opponent.team])
            self.score[self.opponent] = random.poisson(
                xgoal.loc[self.opponent.team, self.team.team])
        else:
            self.score[self.team] = int(xgoal.loc[self.team.team, self.opponent.team])
            self.score[self.opponent] = int(xgoal.loc[self.opponent.team, self.team.team])
        return None

    # Could be further improved to simulate real penalties
    def get_winner(self):
        """Retrieve the game winner"""
        if self.score[self.team] > self.score[self.opponent]:
            winner = self.team
        elif self.score[self.team] < self.score[self.opponent]:
            winner = self.opponent
        else:
            # teamxgoal = self.xgoal.loc[self.team.team, self.opponent.team]
            # opponentxgoal = self.xgoal.loc[self.opponent.team, self.team.team]
            # winner = self.team if teamxgoal >= opponentxgoal else self.opponent
            winner = random.choice([self.team, self.opponent])
        return winner

    def reset(self):
        self.score = {self.team: 0, self.opponent: 0}
        return None

    def display_results(self):
        """Display the game result"""
        print(self.team.team_fifa_code + " " + str(self.score[self.team]) + " - " + str(
            self.score[self.opponent]) + " " + self.opponent.team_fifa_code, end='     ')
        return None
