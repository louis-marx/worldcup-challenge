import time


def line_breaks(n):
    for i in range(n):
        print()
    return None


def add_line_breaks(function):
    """This function add line breaks before and after"""

    def wrapper(*args, **kwargs):
        time.sleep(.1)
        line_breaks(1)
        time.sleep(.1)
        result = function(*args, **kwargs)
        line_breaks(1)
        time.sleep(.1)
        return result

    return wrapper


def display_separators(n, sep):
    print(end=12*' ')
    for i in range(n):
        print(13*sep, end=5*' ')
    print()
    return None
