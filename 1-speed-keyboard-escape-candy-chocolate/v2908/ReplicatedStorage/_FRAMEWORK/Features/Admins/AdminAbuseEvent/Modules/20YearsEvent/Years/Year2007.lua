local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MeleeRagdollTool = require(ReplicatedStorage._FRAMEWORK.Libraries.MeleeRagdollTool)
require(ReplicatedStorage._FRAMEWORK.Libraries.MeleeRagdollTool.Types)
local OrbSupport = require(script.Parent.OrbSupport)
require(script.Parent.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {
	rewardSource = "TwentyYearsEvent:Sword",
	reward = {
		multiplier = 10
	},
	swingCooldownSeconds = 1,
	fling = {
		horizontalSpeed = 120,
		verticalSpeed = 70,
		angularSpeed = 18,
		tripDurationSeconds = 2
	},
	slashAnimationId = "rbxassetid://522635514",
	lungeAnimationId = "rbxassetid://522638767",
	lungeComboWindowSeconds = 0.2,
	lungeDurationSeconds = 0.6
}

local function getSwordTemplate(p, p2: number)
	local yearAssets = p.yearAssets
	local child

	if yearAssets then
		child = yearAssets:FindFirstChild((tostring(p2)))
	end

	local sword

	if child then
		sword = child:FindFirstChild("Sword")
	end

	if sword and sword:IsA("Tool") then
		return sword
	end

	logger:warn(string.format("20th Anniversary Year %d is missing its Sword asset", p2))
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getExistingSoundId(handle, childName: string)
	local sound = handle:FindFirstChild(childName)

	if sound and sound:IsA("Sound") and sound.SoundId ~= "" then
		return sound.SoundId
	end

	return nil
end

local function buildSwordConfig(swordTemplate)
	local handle = swordTemplate:FindFirstChild("Handle")
	local clone = table.clone(v)

	if not handle then
		return clone
	end

	local existingSoundId = getExistingSoundId(handle, "SwordSlash") -- equivalent call inferred; original call site unknown
	clone.swingSoundId = existingSoundId
	local existingSoundId2 = getExistingSoundId(handle, "SwordLunge") -- equivalent call inferred; original call site unknown
	clone.lungeSoundId = existingSoundId2
	local existingSoundId3 = getExistingSoundId(handle, "Unsheath") -- equivalent call inferred; original call site unknown
	clone.unsheathSoundId = existingSoundId3
	return clone
end

local function giveToolToPlayer(p, instance, p2, clones, list)
	local clone = instance:Clone()
	clone.Parent = p.Backpack
	table.insert(clones, clone)
	table.insert(list, MeleeRagdollTool.attach(clone, p2))
end

local Year2007 = {}

function Year2007.load(p, p2: number)
	local loaded, v2 = DefaultYearMap.load(p, 2007)

	if not loaded then
		return nil, v2
	end

	local v3 = OrbSupport.start(p, p2, loaded.map)
	local v4 = {}
	local v5 = {}
	local connections = {}
	local swordTemplate = getSwordTemplate(p, p2)
	local playerAddedConnection

	if swordTemplate then
		local swordConfig = buildSwordConfig(swordTemplate)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function grantSword(p3)
			local success, result = pcall(giveToolToPlayer, p3, swordTemplate, swordConfig, v4, v5)

			if not success then
				logger:warn(result)
			end
		end

		for _, v6 in Players:GetPlayers() do
			if v6.Character then
				grantSword(v6) -- equivalent call inferred; original call site unknown
			end

			local v7 = v6
			table.insert(connections, v6.CharacterAdded:Connect(function()
				grantSword(v7) -- equivalent call inferred; original call site unknown
			end))
		end

		playerAddedConnection = Players.PlayerAdded:Connect(function(player)
			table.insert(connections, player.CharacterAdded:Connect(function()
				grantSword(player) -- equivalent call inferred; original call site unknown
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

		for _, v6 in v5 do
			v6.destroy()
		end

		table.clear(v5)

		for _, v6 in v4 do
			v6:Destroy()
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
			stopTools()
			cleanup()
		end
	}, nil
end

function Year2007.loadClient(p, _: number)
	return OrbSupport.startClient(p)
end

return Year2007