local utils = require("utils")
local debug = require("kgh_debug")
local config = require("config")

-- Set debug in utils
utils.set_debug(debug)

local git = {}

-- Default configurations
local defaults = {
    branch = {
        default_base = "main"
    }
}

-- Helper function to execute git commands
local function execute_git_command(command)
    local full_command = "git " .. command
    if config.dry_run then
        debug.info("🌵 [DRY RUN] Would execute: " .. full_command)
        return true
    end
    
    local result, success = utils.execute_command(full_command)
    if not success then
        debug.error("Git command failed: " .. full_command)
        return false, result
    end
    return true, result
end

-- Create a new branch
function git.newBranch(branch_name)
    debug.info("Creating new branch: " .. branch_name)
    
    -- Check if branch already exists
    local _, result = execute_git_command("branch --list " .. branch_name)
    if result and result ~= "" then
        debug.error("Branch '" .. branch_name .. "' already exists")
        return false, "Branch already exists"
    end
    
    -- Create and checkout new branch
    local success, result = execute_git_command("checkout -b " .. branch_name)
    if not success then
        return false, result
    end
    
    debug.success("Successfully created and checked out branch: " .. branch_name)
    return true, result
end

-- List all branches
function git.listBranches(options)
    options = options or {}
    local command = "branch"
    
    if options.all then
        command = command .. " -a"
    elseif options.remote then
        command = command .. " -r"
    end
    
    return execute_git_command(command)
end

-- Switch to an existing branch
function git.switchBranch(branch_name)
    debug.info("Switching to branch: " .. branch_name)
    return execute_git_command("checkout " .. branch_name)
end

-- Delete a branch
function git.deleteBranch(branch_name, force)
    debug.info("Deleting branch: " .. branch_name)
    local command = "branch " .. (force and "-D" or "-d") .. " " .. branch_name
    return execute_git_command(command)
end

return git 