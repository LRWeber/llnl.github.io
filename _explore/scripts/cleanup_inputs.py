from scraper.github import queryManager as qm

# Take all input lists, process, and write back to file

# Primary Inputs

inputLists = qm.DataManager("../input_lists.json", True)

print("Cleaning primary input lists...")

for listName, aList in inputLists.data.items():
    print("\t%s" % listName)
    aList = [x.lower() for x in aList]  # Standardize as all lowercase
    aList = list(set(aList))  # Remove duplicates
    aList.sort()  # List in alphabetical order
    inputLists.data[listName] = aList

inputLists.fileSave()

print("Primary input lists cleaned!")

# Secondary Inputs

subsetLists = qm.DataManager("../input_lists_subsets.json", True)

print("Cleaning input subset lists...")

for subsetName, setLists in subsetLists.data.items():
    print("\t%s" % subsetName)
    for listName, aList in setLists.items():
        print("\t\t%s" % listName)
        aList = [x.lower() for x in aList]  # Standardize as all lowercase
        aList = list(set(aList))  # Remove duplicates
        aList.sort()  # List in alphabetical order
        subsetLists.data[subsetName][listName] = aList

subsetLists.fileSave()

print("Input subset lists cleaned!")
