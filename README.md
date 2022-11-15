![This is an image](https://www.jumpdesign.co.uk/wp-content/uploads/2021/02/BANNER-LOGO.jpg)

# Predicting FIFA World Cup 2022

## Data

A database was provided to us by the organizers of the challenge.

### Data Transformation

We had to reconfigure the dataset so as to be able to study the performance at team-level for each game, as opposed to studying the outcome at game-level.

| Date | home_team | away_team | home_team_fifa_rank | away_team_fifa_rank | home_team_score | away_team_score | tournament | neutral_location |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 7/10/2018 | France | Belgium | 2 | 5 | 1 | 0 | FIFA World Cup | TRUE |

Transformed into

| Date | team | opponent | fifa_rank_difference | team_score | tournament | team_hosting | opponent_hosting |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 7/10/2018 | France | Belgium | 3 | 1 | FIFA World Cup | False | False |
| 7/10/2018 | Belgium | France | -3 | 0 | FIFA World Cup | False | False |

## Simulation

### Class Diagram

```mermaid
classDiagram
    direction LR
    class Team{
      team
      team_fifa_code
    }
    class Match{
      team
      opponent
      score
      play_game(xgoal)
      get_winner()
      reset()
    }
    class Group{
      id
      teams
      games
      play_games(xgoal)
      rank_teams()
      get_winners()
      reset()
      }
    class Knockout{
      stage
      games
      play_games(xgoal)
      get_winners()
    }
   class Tournament{
      groups
      knockouts
      play_group_stage(xgoal)
      get_groups_winners()
      initialize_knockout_stage(report)
      get_next_knockout(xgoal, report)
      play_knockout_stage(xgoal, report)
      get_winner(report)
   }
   class Report{
      simulations
      proba
      add_team(team)
      update(stage_teams)
      get_report()
   }
   Team --o Match
   Team --o Group
   Team --o Report
   Match --o Group
   Match --o Knockout
   Group --o Tournament
   Knockout --o Tournament
   Report --o Tournament
```
