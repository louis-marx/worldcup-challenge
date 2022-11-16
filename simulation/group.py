from simulation.match import Match


class Group:
    """Group stage"""

    def __init__(self, id, teams):
        """Initialize a tournament pool"""
        self.id = id
        self.teams = teams
        self.games = []
        for i in range(len(self.teams)):
            for j in range(i + 1, len(self.teams)):
                match = Match(self.teams[i], self.teams[j])
                self.games.append(match)
        self.points = {}
        for team in teams:
            self.points[team] = [0, 0, 0]

    def play_games(self, xgoal):
        """Simulate the pool results"""
        for match in self.games:
            match.play_game(xgoal)
            if match.score[match.team] > match.score[match.opponent]:
                self.points[match.team][0] += 3
            elif match.score[match.team] < match.score[match.opponent]:
                self.points[match.opponent][0] += 3
            else:
                self.points[match.team][0] += 1
                self.points[match.opponent][0] += 1
            self.points[match.team][1] += match.score[match.team] - \
                match.score[match.opponent]
            self.points[match.opponent][1] += match.score[match.opponent] - \
                match.score[match.team]
            self.points[match.team][2] += match.score[match.team]
            self.points[match.opponent][2] += match.score[match.opponent]
        return None

    # Need further improvements to take into account the fifa logic in case of a tie
    def rank_teams(self):
        """Rank teams from best to worst"""
        return sorted(self.points.items(), key=lambda item: (item[1][0], item[1][1], item[1][2]), reverse=True)

    def get_winners(self):
        """Retrieve the two group winners"""
        winners = {}
        winners[1] = self.rank_teams()[0][0]
        winners[2] = self.rank_teams()[1][0]
        return winners

    def reset(self):
        for game in self.games:
            game.reset()
        for team in self.teams:
            self.points[team] = [0, 0, 0]
        return None
