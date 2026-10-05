local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local OrbSupport = require(script.Parent.OrbSupport)
local PizzaRewards = require(script.Parent.PizzaRewards)
require(script.Parent.Parent.Types)
local WandererSupport = require(script.Parent.WandererSupport)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = { "Pizza", "PizzaBox" }

local function getToolTemplate(p, p2: number, childName: string)
	local yearAssets = p.yearAssets
	local child

	if yearAssets then
		child = yearAssets:FindFirstChild((tostring(p2)))
	end

	local tool

	if child then
		tool = child:FindFirstChild(childName)
	end

	if tool and tool:IsA("Tool") then
		return tool
	end

	logger:warn(string.format("20th Anniversary Year %d is missing its %s asset", p2, childName))
	return nil
end

local function giveToolToPlayer(p, instance, clones)
	if not (p and instance) then
		logger:warn(string.format("giveToPlayersBackpacks is missing its needed args"))
		return false
	end

	local clone = instance:Clone()
	clone.Parent = p.Backpack

	if clones then
		table.insert(clones, clone)
	end

	return true
end

local function giveToolsToPlayer(p, toolTemplates, p2)
	for _, item in toolTemplates do
		local success, result = pcall(giveToolToPlayer, p, item, p2)

		if not success then
			logger:warn(result)
		end
	end
end

local Year2010 = {}

function Year2010.load(p, p2: number)
	local loaded, v2 = DefaultYearMap.load(p, 2010)

	if not loaded then
		return nil, v2
	end

	local v3 = WandererSupport.start(p, p2, loaded.map)
	local v4 = OrbSupport.start(p, p2, loaded.map)
	local v5 = PizzaRewards.start(p)
	local toolTemplates = {}
	local v6 = {}
	local connections = {}
	local playerAddedConnection = nil

	for _, v7 in v do
		local toolTemplate = getToolTemplate(p, p2, v7)

		if toolTemplate then
			table.insert(toolTemplates, toolTemplate)
		end
	end

	if #toolTemplates > 0 then
		for _, v7 in Players:GetPlayers() do
			if v7.Character then
				giveToolsToPlayer(v7, toolTemplates, v6)
			end

			local v8 = v7
			table.insert(connections, v7.CharacterAdded:Connect(function()
				giveToolsToPlayer(v8, toolTemplates, v6)
			end))
		end

		playerAddedConnection = Players.PlayerAdded:Connect(function(player)
			table.insert(connections, player.CharacterAdded:Connect(function()
				giveToolsToPlayer(player, toolTemplates, v6)
			end))
		end)
	end

	local function stopTools()
		v5()

		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)

		if playerAddedConnection then
			playerAddedConnection:Disconnect()
			playerAddedConnection = nil
		end

		for _, v7 in v6 do
			if v7 then
				v7:Destroy()
			end
		end

		table.clear(v6)
	end

	local cleanup = loaded.cleanup
	return {
		map = loaded.map,
		spawn = loaded.spawn,
		stopTools = stopTools,
		cleanup = function()
			v4()
			v3()
			stopTools()
			cleanup()
		end
	}
end

function Year2010.loadClient(p, p2: number)
	local v2 = WandererSupport.startClient(p2)
	local v3 = OrbSupport.startClient(p)
	return function()
		v3()
		v2()
	end
end

return Year2010