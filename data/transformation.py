import pandas as pd


def data_fetching(file_path):

    # df = pd.read_excel('./data/DA Challenge - Data International Soccer Games.xlsx')
    df = pd.read_excel(file_path)

    ndf = pd.DataFrame(
        columns=['goals', 'team', 'opponent', 'rank', 'host', 'host_oppo'])

    for i in df.index:
        team = pd.Series({'goals': df['home_team_score'][i], 'team': df['home_team'][i], 'opponent': df['away_team'][i],
                         'rank': df['away_team_fifa_rank'][i]-df['home_team_fifa_rank'][i], 'host': not df['neutral_location'][i], 'host_oppo': False})
        opponent = pd.Series({'goals': df['away_team_score'][i], 'team': df['away_team'][i], 'opponent': df['home_team'][i],
                             'rank': df['home_team_fifa_rank'][i]-df['away_team_fifa_rank'][i], 'host': False, 'host_oppo': not df['neutral_location'][i]})
        ndf = pd.concat(
            [ndf, team.to_frame().T, opponent.to_frame().T], ignore_index=True)

    return ndf
