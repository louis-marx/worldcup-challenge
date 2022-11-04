import pandas as pd

class Report:
    """Simulations report"""

    STAGES = ['Round of 16', 'Quarter finals', 'Semi finals', 'Final', 'World Champion']

    def __init__(self, simulations):
        """Initialize a report"""
        self.simulations = simulations
        self.proba = pd.DataFrame(columns=self.STAGES)

    def add_team(self, team):
        self.proba = pd.concat([self.proba, pd.Series(0, index=self.proba.columns, name=team.team_fifa_code).to_frame().T])
        return None
    
    def update(self, stage, teams):
        for team in teams:
            self.proba.loc[team.team_fifa_code, stage] += 1

    def get_report(self):
        order = self.STAGES
        order.reverse()
        return (self.proba.div(self.simulations)*100).sort_values(by=order, ascending=False)
