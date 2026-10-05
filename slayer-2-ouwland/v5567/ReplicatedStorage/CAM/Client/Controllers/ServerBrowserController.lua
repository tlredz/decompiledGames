local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local ServerBrowserStudioServers = require(script.Parent.ServerBrowserStudioServers)
local Teleporter = require(ReplicatedStorage.CAM.Client.Modules.Teleporter)
local Types = require(ReplicatedStorage.Communication.ServerAndClient.ServerBrowser.Types)
local friendsHandler = require(ReplicatedStorage.CAM.Global.friendsHandler)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local ServerBrowserController = {
	Updated = simplesignal.new(),
	Failed = simplesignal.new()
}
local count = 0
local servers = {}
local clone = {}
local thread = nil
local count2 = 0

local function send(state)
	count += 1
	state.stamp = count

	if not RunService:IsStudio() then
		SignalEvent.ToServer("ServerBrowserRequest", state)
		return
	end

	local stamp = count
	task.defer(function()
		local servers2

		if state.action == "search" then
			servers2 = ServerBrowserStudioServers.Search(state.placeId, state.query)
		else
			servers2 = ServerBrowserStudioServers.Browse(state.placeId, state.region)
		end

		ServerBrowserController.applyState({
			Kind = state.action == "search" and "Search" or "Browse",
			PlaceId = state.placeId,
			Region = state.region,
			Query = state.query,
			Servers = servers2,
			Truncated = false,
			Stamp = stamp
		})
	end)
end

local function localMatches(value: string)
	if value == "" then
		return table.clone(clone)
	end

	local v = string.lower(value)
	local result = {}

	for _, v2 in clone do
		if string.find(string.lower(v2.Name), v, 1, true) == nil then
			continue
		end

		table.insert(result, v2)
	end

	return result
end

function ServerBrowserController.Browse(p: number?, region: string?)
	local placeId = p or game.PlaceId

	if typeof(placeId) ~= "number" then
		return
	end

	if thread ~= nil then
		task.cancel(thread)
		thread = nil
	end

	count2 += 1
	local v2 = count2
	task.spawn(function()
		pcall(friendsHandler.getAllOnlineFriends)

		if v2 ~= count2 then
			return
		end

		local jobIds = {}

		for _, currentOnlineFriend in friendsHandler.currentOnlineFriends do
			if #jobIds >= Types.MaxFriendServers then
				break
			end

			if not (currentOnlineFriend.placeId == placeId and currentOnlineFriend.jobId ~= nil and table.find(
				jobIds,
				currentOnlineFriend.jobId
			) == nil) then
				continue
			end

			table.insert(jobIds, currentOnlineFriend.jobId)
		end

		send({
			action = "browse",
			placeId = placeId,
			region = region,
			friendJobs = jobIds
		})
	end)
end

function ServerBrowserController.Search(p: number?, value: string)
	local placeId = p or game.PlaceId

	if typeof(placeId) ~= "number" then
		return
	end

	if thread ~= nil then
		task.cancel(thread)
		thread = nil
	end

	count2 += 1
	local query = string.gsub(value or "", "^%s*(.-)%s*$", "%1")
	local v3 = #query < Types.MinQuery
	servers = localMatches(query)
	ServerBrowserController.Updated:Fire({
		Kind = query == "" and "Browse" or "Search",
		PlaceId = placeId,
		Query = query,
		Servers = servers,
		Stamp = count,
		Partial = not v3
	})

	if v3 then
		return
	end

	thread = task.delay(0.3, function()
		thread = nil
		send({
			action = "search",
			placeId = placeId,
			query = query
		})
	end)
end

function ServerBrowserController.Join(data)
	if typeof(data) ~= "table" or (typeof(data.PlaceId) ~= "number" or typeof(data.JobId) ~= "string") then
		return false, "Invalid server"
	end

	if ServerBrowserController.IsCurrentServer(data) then
		return false, "You're already on this server"
	end

	return Teleporter.Request({
		placeId = data.PlaceId,
		jobId = data.JobId,
		allowFallback = false
	}, {
		Title = "Joining Server",
		SubTitle = data.Name
	})
end

function ServerBrowserController.IsCurrentServer(p)
	if typeof(p) ~= "table" then
		return false
	end

	local ownServerName = ServerBrowserController.OwnServerName()
	return ownServerName ~= nil and p.PlaceId == game.PlaceId and p.Name == ownServerName
end

function ServerBrowserController.UptimeOf(p)
	if typeof(p) == "table" and typeof(p.StartTime) == "number" then
		return (math.max(0, workspace:GetServerTimeNow() - p.StartTime))
	end

	return 0
end

function ServerBrowserController.GetCached()
	return servers
end

function ServerBrowserController.OwnServerName()
	local serverName = workspace:GetAttribute("ServerName")

	if typeof(serverName) == "string" then
		return serverName
	end

	return nil
end

function ServerBrowserController.CurrentRegion()
	local serverRegion = workspace:GetAttribute("ServerRegion")

	if typeof(serverRegion) == "string" then
		return serverRegion
	end

	return Types.Unknown
end

function ServerBrowserController.Regions()
	return table.clone(Types.Regions)
end

function ServerBrowserController.applyState(clone2)
	if not (typeof(clone2) == "table" and clone2.Stamp == count) then
		return
	end

	if clone2.Failed ~= nil then
		ServerBrowserController.Failed:Fire(clone2.Failed)
		return
	end

	if typeof(clone2.Servers) ~= "table" then
		return
	end

	for _, server in clone2.Servers do
		local names = {}

		for _, currentOnlineFriend in friendsHandler.currentOnlineFriends do
			if currentOnlineFriend.placeId == clone2.PlaceId and currentOnlineFriend.jobId == server.JobId then
				table.insert(names, currentOnlineFriend.name)
			end
		end

		if #names > 0 then
			server.Friends = names
		end
	end

	if clone2.Kind == "Browse" then
		clone = table.clone(clone2.Servers)
		servers = clone2.Servers
	else
		local clone3 = table.clone(clone2.Servers)
		local v = {}

		for _, v2 in clone3 do
			v[v2.JobId] = true
		end

		for _, v2 in localMatches(clone2.Query or "") do
			if v[v2.JobId] ~= nil then
				continue
			end

			v[v2.JobId] = true
			table.insert(clone3, v2)
		end

		servers = clone3
		clone2 = table.clone(clone2)
		clone2.Servers = clone3
	end

	ServerBrowserController.Updated:Fire(clone2)
end

return ServerBrowserController