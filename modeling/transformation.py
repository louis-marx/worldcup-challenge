import pandas as pd

df = pd.read_excel(
    './data/DA Challenge - Data International Soccer Games.xlsx')

ndf = pd.DataFrame(
    columns=['goals', 'team', 'opponent', 'rank', 'host', 'host_oppo'])

for i in df.index:
    team = pd.Series({'goals': df['home_team_score'][i], 'team': df['home_team'][i], 'opponent': df['away_team'][i], 'rank': df['away_team_fifa_rank']
                     [i]-df['home_team_fifa_rank'][i], 'host': not df['neutral_location'][i], 'host_oppo': False})
    opponent = pd.Series({'goals': df['away_team_score'][i], 'team': df['away_team'][i], 'opponent': df['home_team'][i],
                         'rank': df['home_team_fifa_rank'][i]-df['away_team_fifa_rank'][i], 'host': False, 'host_oppo': not df['neutral_location'][i]})
    ndf = pd.concat(
        [ndf, team.to_frame().T, opponent.to_frame().T], ignore_index=True)

print(ndf)


# ndf = pd.DataFrame(columns=['goals', 'tournament', 'city', 'country', 'team', 'team_continent', 'team_fifa_rank', 'team_fifa_points', 'team_goalkeeper_score', 'team_defense_score', 'team_a_midfield_score', 'team_a_offense_score', 'team_b', 'team_b_continent', 'team_b_fifa_rank', 'team_b_fifa_points', 'team_b_goalkeeper_score', 'team_b_defense_score', 'team_b_midfield_score', 'team_b_offense_score','team_a_score'])
