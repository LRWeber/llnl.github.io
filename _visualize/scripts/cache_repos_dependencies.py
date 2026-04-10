from scraper.github import queryManager as qm
from os import environ as env

ghDataDir = env.get("GITHUB_DATA", "../github-data")
queryPath = "../queries/repo-Dependencies.gql"

# Read repo info data file (to use as repo list)
inputLists = qm.DataManager("%s/intReposInfo.json" % ghDataDir, True)
# Populate repo list
repolist = []
print("Getting internal repos ...")
repolist = sorted(inputLists.data["data"].keys())
print("Repo list complete. Found %d repos." % (len(repolist)))

# Initialize query manager
queryMan = qm.GitHubQueryManager(maxRetry=1, retryDelay=1)

# Iterate through internal repos
print("Gathering data across multiple paginated queries...")
for repo in repolist:
    print("\n'%s'" % (repo))

    r = repo.split("/")
    try:
        outObj = queryMan.queryGitHubFromFile(
            queryPath,
            {
                "ownName": r[0],
                "repoName": r[1],
                "numManifests": 25,
                "numDependents": 100,
                "pgCursor": None,
            },
            paginate=True,
            cursorVar="pgCursor",
            keysToList=["data", "repository", "dependencyGraphManifests", "nodes"],
        )
    except Exception as error:
        print("Warning: Could not complete '%s'" % (repo))
        print(error)
        continue

    print("'%s' Done!" % (repo))

print("\nCollective data gathering complete!")

print("\nDone!\n")
