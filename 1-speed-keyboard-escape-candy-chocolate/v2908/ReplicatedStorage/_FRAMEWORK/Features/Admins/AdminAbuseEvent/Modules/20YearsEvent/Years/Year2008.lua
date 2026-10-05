local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local DestructibleSupport = require(script.Parent.DestructibleSupport)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local OrbSupport = require(script.Parent.OrbSupport)
local RocketAim = require(script.Parent.RocketAim)
require(script.Parent.Parent.Types)
local WandererSupport = require(script.Parent.WandererSupport)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

local function getToolTemplate(p, p2: number)
	local yearAssets = p.yearAssets
	local child

	if yearAssets then
		child = yearAssets:FindFirstChild((tostring(p2)))
	end

	local rocketLauncher

	if child then
		rocketLauncher = child:FindFirstChild("RocketLauncher")
	end

	if rocketLauncher and rocketLauncher:IsA("Tool") then
		return rocketLauncher
	end

	logger:warn(string.format("20th Anniversary Year %d is missing its %s asset", p2, "RocketLauncher"))
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

local Year2008 = {}

function Year2008.load(p, p2: number)
	local loaded, v = DefaultYearMap.load(p, 2008)

	if not loaded then
		return nil, v
	end

	local v2 = WandererSupport.start(p, p2, loaded.map)
	local v3 = OrbSupport.start(p, p2, loaded.map, OrbSupport.doubledOrbConfig)
	DestructibleSupport.start(loaded.map)
	local v4 = {}
	local connections = {}
	local toolTemplate = getToolTemplate(p, p2)
	local playerAddedConnection

	if toolTemplate then
		for _, v5 in Players:GetPlayers() do
			if v5.Character then
				local success, result = pcall(giveToolToPlayer, v5, toolTemplate, v4)

				if not success then
					logger:warn(result)
				end
			end

			local v6 = v5
			table.insert(connections, v5.CharacterAdded:Connect(function()
				local success, result = pcall(giveToolToPlayer, v6, toolTemplate, v4)

				if not success then
					logger:warn(result)
				end
			end))
		end

		playerAddedConnection = Players.PlayerAdded:Connect(function(player)
			table.insert(connections, player.CharacterAdded:Connect(function()
				local success, result = pcall(giveToolToPlayer, player, toolTemplate, v4)

				if not success then
					logger:warn(result)
				end
			end))
		end)
	else
		playerAddedConnection = nil
	end

	local function stopTools()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)

		if playerAddedConnection then
			playerAddedConnection:Disconnect()
			playerAddedConnection = nil
		end

		for _, v5 in v4 do
			if v5 then
				v5:Destroy()
			end
		end

		table.clear(v4)
	end

	local cleanup = loaded.cleanup
	return {
		map = loaded.map,
		spawn = loaded.spawn,
		stopTools = stopTools,
		cleanup = function()
			v3()
			v2()
			stopTools()
			cleanup()
		end
	}
end

function Year2008.loadClient(p, p2: number)
	local v = RocketAim.start()
	local v2 = WandererSupport.startClient(p2)
	local v3 = OrbSupport.startClient(p, OrbSupport.doubledOrbConfig)
	local v4 = DestructibleSupport.startClient(p, p2)
	return function()
		v()
		v4()
		v3()
		v2()
	end
end

return Year2008