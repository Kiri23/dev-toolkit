-- gh.lua - Pure GitHub module (Layer 1: Building Blocks)
-- This module provides pure functions for GitHub operations without side effects
-- All functions return command objects rather than executing them directly

local gh = {}

-- Pull Request functions
function gh.createPr(options)
    options = options or {}
    local cmd = {"gh", "pr", "create"}
    
    if options.title then
        table.insert(cmd, "--title")
        table.insert(cmd, options.title)
    end
    
    if options.body then
        table.insert(cmd, "--body")
        table.insert(cmd, options.body)
    end
    
    if options.base then
        table.insert(cmd, "--base")
        table.insert(cmd, options.base)
    end
    
    if options.head then
        table.insert(cmd, "--head")
        table.insert(cmd, options.head)
    end
    
    if options.draft then
        table.insert(cmd, "--draft")
    end
    
    if options.assignee then
        table.insert(cmd, "--assignee")
        table.insert(cmd, options.assignee)
    end
    
    if options.reviewer then
        table.insert(cmd, "--reviewer")
        table.insert(cmd, options.reviewer)
    end
    
    if options.label then
        if type(options.label) == "table" then
            for _, label in ipairs(options.label) do
                table.insert(cmd, "--label")
                table.insert(cmd, label)
            end
        else
            table.insert(cmd, "--label")
            table.insert(cmd, options.label)
        end
    end
    
    return cmd
end

function gh.listPrs(options)
    options = options or {}
    local cmd = {"gh", "pr", "list"}
    
    if options.state then
        table.insert(cmd, "--state")
        table.insert(cmd, options.state)
    end
    
    if options.author then
        table.insert(cmd, "--author")
        table.insert(cmd, options.author)
    end
    
    if options.assignee then
        table.insert(cmd, "--assignee")
        table.insert(cmd, options.assignee)
    end
    
    if options.label then
        table.insert(cmd, "--label")
        table.insert(cmd, options.label)
    end
    
    if options.limit then
        table.insert(cmd, "--limit")
        table.insert(cmd, tostring(options.limit))
    end
    
    return cmd
end

function gh.viewPr(number, options)
    options = options or {}
    local cmd = {"gh", "pr", "view"}
    
    if number then
        table.insert(cmd, tostring(number))
    end
    
    if options.web then
        table.insert(cmd, "--web")
    end
    
    if options.comments then
        table.insert(cmd, "--comments")
    end
    
    return cmd
end

function gh.mergePr(number, options)
    options = options or {}
    local cmd = {"gh", "pr", "merge"}
    
    if number then
        table.insert(cmd, tostring(number))
    end
    
    if options.merge then
        table.insert(cmd, "--merge")
    elseif options.squash then
        table.insert(cmd, "--squash")
    elseif options.rebase then
        table.insert(cmd, "--rebase")
    end
    
    if options.delete_branch then
        table.insert(cmd, "--delete-branch")
    end
    
    return cmd
end

function gh.closePr(number, options)
    options = options or {}
    local cmd = {"gh", "pr", "close"}
    
    if number then
        table.insert(cmd, tostring(number))
    end
    
    if options.comment then
        table.insert(cmd, "--comment")
        table.insert(cmd, options.comment)
    end
    
    if options.delete_branch then
        table.insert(cmd, "--delete-branch")
    end
    
    return cmd
end

-- Issue functions
function gh.createIssue(options)
    options = options or {}
    local cmd = {"gh", "issue", "create"}
    
    if options.title then
        table.insert(cmd, "--title")
        table.insert(cmd, options.title)
    end
    
    if options.body then
        table.insert(cmd, "--body")
        table.insert(cmd, options.body)
    end
    
    if options.assignee then
        table.insert(cmd, "--assignee")
        table.insert(cmd, options.assignee)
    end
    
    if options.label then
        if type(options.label) == "table" then
            for _, label in ipairs(options.label) do
                table.insert(cmd, "--label")
                table.insert(cmd, label)
            end
        else
            table.insert(cmd, "--label")
            table.insert(cmd, options.label)
        end
    end
    
    if options.milestone then
        table.insert(cmd, "--milestone")
        table.insert(cmd, options.milestone)
    end
    
    return cmd
end

function gh.listIssues(options)
    options = options or {}
    local cmd = {"gh", "issue", "list"}
    
    if options.state then
        table.insert(cmd, "--state")
        table.insert(cmd, options.state)
    end
    
    if options.author then
        table.insert(cmd, "--author")
        table.insert(cmd, options.author)
    end
    
    if options.assignee then
        table.insert(cmd, "--assignee")
        table.insert(cmd, options.assignee)
    end
    
    if options.label then
        table.insert(cmd, "--label")
        table.insert(cmd, options.label)
    end
    
    if options.limit then
        table.insert(cmd, "--limit")
        table.insert(cmd, tostring(options.limit))
    end
    
    return cmd
end

function gh.viewIssue(number, options)
    options = options or {}
    local cmd = {"gh", "issue", "view"}
    
    if number then
        table.insert(cmd, tostring(number))
    end
    
    if options.web then
        table.insert(cmd, "--web")
    end
    
    if options.comments then
        table.insert(cmd, "--comments")
    end
    
    return cmd
end

function gh.closeIssue(number, options)
    options = options or {}
    local cmd = {"gh", "issue", "close"}
    
    if number then
        table.insert(cmd, tostring(number))
    end
    
    if options.comment then
        table.insert(cmd, "--comment")
        table.insert(cmd, options.comment)
    end
    
    if options.reason then
        table.insert(cmd, "--reason")
        table.insert(cmd, options.reason)
    end
    
    return cmd
end

-- Repository functions
function gh.repoView(repo, options)
    options = options or {}
    local cmd = {"gh", "repo", "view"}
    
    if repo then
        table.insert(cmd, repo)
    end
    
    if options.web then
        table.insert(cmd, "--web")
    end
    
    return cmd
end

function gh.repoClone(repo, options)
    options = options or {}
    local cmd = {"gh", "repo", "clone"}
    
    if repo then
        table.insert(cmd, repo)
    end
    
    if options.directory then
        table.insert(cmd, options.directory)
    end
    
    return cmd
end

function gh.repoFork(repo, options)
    options = options or {}
    local cmd = {"gh", "repo", "fork"}
    
    if repo then
        table.insert(cmd, repo)
    end
    
    if options.clone then
        table.insert(cmd, "--clone")
    end
    
    if options.remote then
        table.insert(cmd, "--remote")
    end
    
    return cmd
end

-- Release functions
function gh.listReleases(options)
    options = options or {}
    local cmd = {"gh", "release", "list"}
    
    if options.limit then
        table.insert(cmd, "--limit")
        table.insert(cmd, tostring(options.limit))
    end
    
    return cmd
end

function gh.viewRelease(tag, options)
    options = options or {}
    local cmd = {"gh", "release", "view"}
    
    if tag then
        table.insert(cmd, tag)
    end
    
    if options.web then
        table.insert(cmd, "--web")
    end
    
    return cmd
end

-- Workflow functions
function gh.listWorkflows(options)
    options = options or {}
    local cmd = {"gh", "workflow", "list"}
    
    if options.all then
        table.insert(cmd, "--all")
    end
    
    return cmd
end

function gh.runWorkflow(workflow, options)
    options = options or {}
    local cmd = {"gh", "workflow", "run"}
    
    if workflow then
        table.insert(cmd, workflow)
    end
    
    if options.ref then
        table.insert(cmd, "--ref")
        table.insert(cmd, options.ref)
    end
    
    return cmd
end

-- Passthrough function for unsupported commands
function gh.passthrough(args)
    local cmd = {"gh"}
    for _, arg in ipairs(args) do
        table.insert(cmd, arg)
    end
    return cmd
end

return gh