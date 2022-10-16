from simulation.match import Match


class Group:
    """Tournament group stage"""

    def __init__(self, group, teams, games=[], points={}):
        """Initialize a tournament pool"""
        self.group = group
        self.teams = teams
        self.games = games
        for i in range(len(self.teams)):
            for j in range(i + 1, len(self.teams)):
                match = Match(self.teams[i], self.teams[j])
                self.games.append(match)
        self.points = points
        for team in teams:
            self.points[team] = 0

    def play_games(self):
        for match in self.games:
            match.play_game()
            if match.score[0] > match.score[1]:
                self.points[match.team_a] += 3
            elif match.score[0] == match.score[1]:
                self.points[match.team_a] += 1
                self.points[match.team_b] += 1
            else:
                self.points[match.team_b] += 3
        return self.games

    def display_games(self):
        for match in self.games:
            print(match.display_results())
        return None

    def display_points(self):
        results = ""
        for key, value in self.points.items():
            results += key.fifa_code + " " + str(value) + "\n"
        return results

    def get_results(self):
        print("\n##### GROUP " + self.group + " #####")
        self.play_games()
        print()
        self.display_games()
        print()
        print(self.display_points())
        return None
