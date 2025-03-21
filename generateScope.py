import sys
location = sys.argv[1]

template = """
const HOUSE_LOCATION_INSTANCES = [%s]

const NUMBER_OF_HOUSEHOLDS = sum([THEORETICAL_NUMBER_OF_HOUSES_MAP[location] for location in HOUSE_LOCATION_INSTANCES]) / 2
"""

with open("scope.jl", "w") as f:
    f.write(template % location)