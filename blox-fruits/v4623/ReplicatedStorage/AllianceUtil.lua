local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage.Util.Signal2)

function getAllianceTagFromName(p: string)
	return "Ally" .. p
end

function getIfAllied(instance, instance2)
	return instance:HasTag(getAllianceTagFromName(instance2.Name)) and instance2:HasTag(getAllianceTagFromName(instance.Name))
end

function getAllies(p)
	local result = {}

	for _, v in ipairs(Players:GetPlayers()) do
		if v ~= p and getIfAllied(v, p) then
			table.insert(result, v)
		end
	end

	table.freeze(result)
	return result
end

function getRemoteEventAsync(name: string)
	if RunService:IsServer() then
		local remoteEvent = script:FindFirstChild(name)

		if remoteEvent then
			assert(remoteEvent:IsA("RemoteEvent"), (`bad remoteEvent {name}`))
			return remoteEvent
		end

		local remoteEvent2 = Instance.new("RemoteEvent")
		remoteEvent2.Name = name
		remoteEvent2.Parent = script
		return remoteEvent2
	else
		local remoteEvent = script:WaitForChild(name)
		assert(remoteEvent and remoteEvent:IsA("RemoteEvent"), (`bad remoteEvent {name}`))
		return remoteEvent
	end
end

if RunService:IsServer() then
	getRemoteEventAsync("OnAllianceStart")
	getRemoteEventAsync("OnAllianceEnd")
end

local AllianceUtil = {}
AllianceUtil.ON_ALLY_START_EVENT_NAME = "OnAllianceStart"
AllianceUtil.ON_ALLY_END_EVENT_NAME = "OnAllianceEnd"
AllianceUtil.getIfAllied = getIfAllied
AllianceUtil.getAllies = getAllies
AllianceUtil.getAllianceTagFromName = getAllianceTagFromName
AllianceUtil.getRemoteEventAsync = getRemoteEventAsync

function AllianceUtil.clientConnectOnAllianceStart(onOnClientEvent)
	local remoteEventAsync = getRemoteEventAsync("OnAllianceStart")
	assert(RunService:IsClient(), "client-only")
	return remoteEventAsync.OnClientEvent:Connect(onOnClientEvent)
end

function AllianceUtil.clientConnectOnAllianceEnd(onOnClientEvent)
	local remoteEventAsync = getRemoteEventAsync("OnAllianceEnd")
	assert(RunService:IsClient(), "client-only")
	return remoteEventAsync.OnClientEvent:Connect(onOnClientEvent)
end

return AllianceUtil