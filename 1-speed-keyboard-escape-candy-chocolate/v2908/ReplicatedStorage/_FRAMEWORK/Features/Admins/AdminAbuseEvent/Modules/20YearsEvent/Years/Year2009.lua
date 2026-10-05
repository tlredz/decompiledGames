local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local DestructibleSupport = require(script.Parent.DestructibleSupport)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local OrbSupport = require(script.Parent.OrbSupport)
require(script.Parent.Parent.Types)
local WandererSupport = require(script.Parent.WandererSupport)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

local function collectToolTemplates(p, p2: number)
	local yearAssets = p.yearAssets
	local child

	if yearAssets then
		child = yearAssets:FindFirstChild((tostring(p2)))
	end

	local tools

	if child then
		tools = child:FindFirstChild("Tools")
	end

	local tools2 = {}

	if tools then
		for _, tool in tools:GetChildren() do
			if tool:IsA("Tool") then
				table.insert(tools2, tool)
			end
		end
	end

	return tools2
end

local function giveTools(instance, items, clones)
	for _, item in items do
		local clone = item:Clone()
		clone.Parent = instance:FindFirstChildOfClass("Backpack")
		table.insert(clones, clone)
	end
end

local function startTools(p)
	local v = {}
	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function safeGiveTools(p2)
		local success, result = pcall(giveTools, p2, p, v)

		if not success then
			logger:warn(string.format("Failed to give 20th Anniversary tools to %s: %s", p2.Name, (tostring(result))))
		end
	end

	local function watchPlayer(p2)
		table.insert(connections, p2.CharacterAdded:Connect(function()
			safeGiveTools(p2) -- equivalent call inferred; original call site unknown
		end))
	end

	for _, v2 in Players:GetPlayers() do
		if v2.Character then
			safeGiveTools(v2) -- equivalent call inferred; original call site unknown
		end

		local v3 = v2
		table.insert(connections, v2.CharacterAdded:Connect(function()
			safeGiveTools(v3) -- equivalent call inferred; original call site unknown
		end))
	end

	table.insert(connections, Players.PlayerAdded:Connect(watchPlayer))
	return function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)

		for _, v2 in v do
			v2:Destroy()
		end

		table.clear(v)
	end
end

local Year2009 = {}

function Year2009.load(p, p2: number)
	local loaded, v = DefaultYearMap.load(p, 2009)

	if not loaded then
		return nil, v
	end

	local v2 = collectToolTemplates(p, p2)

	local function fn() end

	if #v2 > 0 then
		fn = startTools(v2)
	else
		logger:warn(string.format("20th Anniversary Year %d needs a Tools folder containing Tool instances", p2))
	end

	local v3 = WandererSupport.start(p, p2, loaded.map)
	local v4 = OrbSupport.start(p, p2, loaded.map, OrbSupport.doubledOrbConfig)
	DestructibleSupport.start(loaded.map)
	local cleanup = loaded.cleanup
	return {
		map = loaded.map,
		spawn = loaded.spawn,
		stopTools = fn,
		cleanup = function()
			v4()
			v3()
			fn()
			cleanup()
		end
	}, nil
end

function Year2009.loadClient(p, p2: number)
	local v = WandererSupport.startClient(p2)
	local v2 = OrbSupport.startClient(p, OrbSupport.doubledOrbConfig)
	local v3 = DestructibleSupport.startClient(p, p2)
	return function()
		v3()
		v2()
		v()
	end
end

return Year2009