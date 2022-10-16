from simulation.team import Team
from simulation.group import Group


def main():
    """Main function."""
    france = Team("France", "FRA", 1759.78)
    spain = Team("Spain", "ESP", 1715.22)
    argentina = Team("Argentina", "ARG", 1773.88)
    england = Team("England", "ENG", 1728.47)

    group_a = [france, spain, argentina, england]

    group = Group("A", group_a)
    group.get_results()


if __name__ == "__main__":
    main()
