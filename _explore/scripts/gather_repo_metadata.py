from scraper.github import queryManager as qm
from os import environ as env

ghDataDir = env.get("GITHUB_DATA", "../github-data")
genDatafile = "%s/labReposInfo.json" % ghDataDir
topicsDatafile = "%s/labRepos_Topics.json" % ghDataDir
writeFile = "%s/labRepo_Metadata.json" % ghDataDir

# initialize data manager and load repo info
genDataCollector = qm.DataManager(genDatafile, True)

# initialize data manager and load repo topics
topicsCollector = qm.DataManager(topicsDatafile, True)

# initialize data manager to write collected info
infoWriter = qm.DataManager(writeFile, False)

print("\nGathering repo metadata...\n")

# iterate through repos
for repo, repoObj in genDataCollector.data["data"].items():

    repoData = {}
    repoData["name"] = repo
    repoData["description"] = repoObj["description"]
    repoData["website"] = repoObj["homepageUrl"]

    # gather any repo topics
    if repoObj["repositoryTopics"]["totalCount"] > 0:
        repoTopicData = topicsCollector.data["data"][repo]
        repoData["topics"] = [
            topicObj["topic"]["name"]
            for topicObj in repoTopicData["repositoryTopics"]["nodes"]
        ]
    else:
        repoData["topics"] = None

    # record info for this repo
    infoWriter.data[repo] = repoData

# write data to file
infoWriter.fileSave()

print("\nDone!\n")
