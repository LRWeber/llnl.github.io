from scraper.github import queryManager as qm
from collections import defaultdict
from os import environ as env
import os.path
import re

ghDataDir = env.get("GITHUB_DATA", "../github-data")
yearData = qm.DataManager("%s/YEARS.json" % ghDataDir, False)
yearDict = defaultdict(list)

# Gather all file name data
print("Checking GitHub data file names with year stamps...")
if not os.path.exists(ghDataDir):
    raise FileNotFoundError("Directory path '%s' does not exist." % (ghDataDir))
yearlyFiles = list(
    filter(lambda x: re.fullmatch(r"^\w+?\.\d{4}\.json$", x), os.listdir(ghDataDir))
)  # Files must have format "somePrefix.0000.json"
for file in yearlyFiles:
    nameSplit = file.split(".")
    yearDict[nameSplit[0]].append(nameSplit[1])

yearDict = dict(yearDict)  # Convert to normal dictionary

print("Sorting year data...")
for prefix, yearList in yearDict.items():
    yearList.sort()

yearData.data = yearDict
yearData.fileSave()

print("Done!\n")
