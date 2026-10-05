local DungeonShared = {}
require(game.ReplicatedStorage.Util.Maid)
require(game.ReplicatedStorage.Modules.Component)
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local RunService2 = game:GetService("RunService")
local isClient = RunService2:IsClient()
local class = {}
class.__index = class

function class.getNamed(items, p: string)
	local result = {}

	for _, item in pairs(items) do
		if item.Instance and item.Instance.Name == p then
			table.insert(result, item)
		end
	end

	return result
end

function class.getTagged(items, p: string)
	local result = {}

	for _, item in pairs(items) do
		if item.Instance and item.Tag == p then
			table.insert(result, item)
		end
	end

	return result
end

DungeonShared.MapComponents = {}

function DungeonShared.getComponentsOnFloor(p: string)
	local mapComponent = DungeonShared.MapComponents[p]

	if not mapComponent then
		DungeonShared.MapComponents[p] = setmetatable({}, class)
		mapComponent = DungeonShared.MapComponents[p]
	end

	return mapComponent
end

task.defer(function()
	for _, moduleScript in pairs((script.MapComponents:GetChildren())) do
		local v = DungeonShared
		local name = moduleScript.Name
		local module = require(moduleScript)
		v[name] = module
	end
end)
local RunService3 = game:GetService("RunService")
local v

if RunService3:IsServer() then
	v = Instance.new("RemoteEvent", script)
	v.Name = "SystemChatRemote"
else
	v = script:WaitForChild("SystemChatRemote", 1e999)
end

local systemChat = {}
DungeonShared.SystemChat = systemChat

function systemChat.sendMessageToPlayer(player, p: string, p2)
	assert(isServer, "SystemChat.sendMessageToPlayer can only be called from the server")
	v:FireClient(player, p, p2)
end

function systemChat.broadcastMessage(p: string)
	assert(isServer, "SystemChat.broadcastMessage can only be called from the server")
	v:FireAllClients(p)
end

if not isClient then
	return DungeonShared
end

local TextChatService = game:GetService("TextChatService")
local rBXGeneral = TextChatService.TextChannels:WaitForChild("RBXGeneral", 1e999)
v.OnClientEvent:Connect(function(p: string, p2)
	local v4

	if p2 then
		local HttpService = game:GetService("HttpService")
		v4 = HttpService:JSONEncode(p2) or "[]"
	else
		v4 = "[]"
	end

	rBXGeneral:DisplaySystemMessage(p, v4)
end)
local TextChatService2 = game:GetService("TextChatService")
local chatWindowConfiguration = TextChatService2:FindFirstChildOfClass("ChatWindowConfiguration")

rBXGeneral.OnIncomingMessage = function(p)
	local success, _ = pcall(function()
		local HttpService = game:GetService("HttpService")
		return (HttpService:JSONDecode(p.Metadata))
	end)

	if not success then
		return
	end

	local newMessageProperties = chatWindowConfiguration:DeriveNewMessageProperties()
	newMessageProperties.Text = `{p.Text}`
	return newMessageProperties
end

return DungeonShared