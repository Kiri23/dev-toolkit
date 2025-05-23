local git = require("git")
local debug = require("kgh_debug")

-- Enable debug mode for testing
debug.enable()

-- Test new branch creation
print("\nTesting new branch creation...")
local success, result = git.newBranch("test-branch")
print("Result:", success, result)

-- Test branch listing
print("\nTesting branch listing...")
success, result = git.listBranches({all = true})
print("Result:", success, result)

-- Test branch switching
print("\nTesting branch switching...")
success, result = git.switchBranch("main")
print("Result:", success, result)

-- Test branch deletion
print("\nTesting branch deletion...")
success, result = git.deleteBranch("test-branch", true)
print("Result:", success, result) 