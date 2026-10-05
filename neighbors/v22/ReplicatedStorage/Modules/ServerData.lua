local ServerData = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Types)
local Network = require(ReplicatedStorage.Modules.Network)
local FastSignal = require(ReplicatedStorage.Modules.FastSignal)
local Tags = require(ReplicatedStorage.Assets.Data.Tags)
local localPlayer = Players.LocalPlayer
local servers = {}
local v = {}
local playerCounts = {}
local customServers = {}
local v3 = true
ServerData.PastServersUpdated = FastSignal.new()
ServerData.ServersUpdated = FastSignal.new()
ServerData.CustomServersUpdated = FastSignal.new()

function ServerData.Refresh(_)
	local v4 = v3
	v3 = false

	if v4 then
		localPlayer:SetAttribute("LoadingServers", true)
	end

	local v5 = Network:invoke("GetServerList")

	if v5 then
		servers = v5.Servers
		playerCounts = v5.PlayerCounts

		for _, server in next, servers, nil do
			if not server.Tags then
				continue
			end

			local tagsByTagFromId = {}

			for k, tag in next, server.Tags, nil do
				local tagFromId = Tags:GetTagFromId(k)

				if tagFromId then
					tagsByTagFromId[tagFromId] = tag
				end
			end

			server.Tags = tagsByTagFromId
		end

		ServerData.Servers = servers
	end

	if v4 then
		localPlayer:SetAttribute("LoadingServers", nil)
	end

	if v5 then
		ServerData.ServersUpdated:Fire()
	end
end

function ServerData.GetServerFromJobId(_, p: string)
	return servers[p]
end

function ServerData.GetCustomServer(_, p: string)
	for _, v4 in next, customServers, nil do
		if v4.ReserveId == p then
			return v4
		end
	end

	return nil
end

function ServerData.GetPastServer(_, p: string)
	return v[p]
end

function ServerData.GetPlayerCount(_, p: number)
	return playerCounts[tostring(p)] or 0
end

Network:listen("UpdatePastServers", function(p)
	v = p
	ServerData.PastServersUpdated:Fire()
end)
Network:listen("UpdateCustomServerList", function(p)
	customServers = p
	ServerData.CustomServers = customServers
	ServerData.CustomServersUpdated:Fire()
end)
ServerData.Servers = servers
ServerData.CustomServers = customServers
return ServerData