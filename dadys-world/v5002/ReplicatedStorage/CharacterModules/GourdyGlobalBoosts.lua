local GourdyGlobalBoosts = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Debris")
game:GetService("RunService")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local BuffIndicator = require(ReplicatedStorage.Modules.Gameplay.BuffIndicator)
local Players = game:GetService("Players")
local v = {}
local flag = false
local flag2 = false
local v2 = {}
local v3 = {}
local threads = {}

local function hasAliveGourdy()
	for k, _ in pairs(v) do
		if k.Parent then
			if k:GetAttribute("isDead") ~= true then
				return true
			end
		else
			v[k] = nil
		end
	end

	return false
end

function GourdyGlobalBoosts.RegisterGourdy(character)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	if playerFromCharacter then
		v[playerFromCharacter] = true
	end
end

function GourdyGlobalBoosts.UnregisterGourdy(instance)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		v[playerFromCharacter] = nil
	end

	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health > 0 and instance.Parent ~= nil then
		return
	end

	if not hasAliveGourdy() then
		GourdyGlobalBoosts.CleanupAllBoosts()
	end
end

local function applySpeedBoost(child, p)
	local playerFromCharacter = Players:GetPlayerFromCharacter(child)

	if not playerFromCharacter or playerFromCharacter:GetAttribute("isDead") == true or not child:FindFirstChild("Stats") then
		return
	end

	local v4 = "Gourdy_" .. p
	local v5 = StatModifierManager.ApplySpeedModifiers(child, 1.2, v4, {
		category = "ability",
		antiCheat = true
	})

	if p == "Elevator" then
		v2[child] = v5
	else
		v3[child] = v5
	end

	BuffIndicator.raise(child, "GourdySugarRush", 5)
	BuffIndicator.tell(child, string.format("Gourdy's Sugar Rush! Speed +%d%% for %s!", 20, BuffIndicator.seconds(5)))
end

local function removeSpeedBoost(p, p2)
	local v4

	if p2 == "Elevator" then
		v4 = v2[p]
		v2[p] = nil
	else
		v4 = v3[p]
		v3[p] = nil
	end

	if v4 then
		StatModifierManager.RemoveSpeedModifiers(p, v4)
	end

	if not (v2[p] or v3[p]) then
		BuffIndicator.clear(p, "GourdySugarRush")
	end
end

function GourdyGlobalBoosts.TryApplyElevatorBoost()
	if flag or not hasAliveGourdy() then
		return
	end

	flag = true
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in pairs(inGamePlayers:GetChildren()) do
			if child and child:FindFirstChild("Humanoid") then
				applySpeedBoost(child, "Elevator")
			end
		end
	end

	local thread = task.delay(5, function()
		if not flag then
			return
		end

		local inGamePlayers2 = workspace:FindFirstChild("InGamePlayers")

		if inGamePlayers2 then
			for _, child in pairs(inGamePlayers2:GetChildren()) do
				if not (child and child:FindFirstChild("Humanoid")) then
					continue
				end

				local v4 = v2[child]
				v2[child] = nil

				if v4 then
					StatModifierManager.RemoveSpeedModifiers(child, v4)
				end

				if not (v2[child] or v3[child]) then
					BuffIndicator.clear(child, "GourdySugarRush")
				end
			end
		end

		flag = false
	end)
	table.insert(threads, thread)
end

function GourdyGlobalBoosts.TryApplyPanicBoost()
	if flag2 or not hasAliveGourdy() then
		return
	end

	flag2 = true
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in pairs(inGamePlayers:GetChildren()) do
			if child and child:FindFirstChild("Humanoid") then
				applySpeedBoost(child, "Panic")
			end
		end
	end

	local thread = task.delay(5, function()
		if not flag2 then
			return
		end

		local inGamePlayers2 = workspace:FindFirstChild("InGamePlayers")

		if inGamePlayers2 then
			for _, child in pairs(inGamePlayers2:GetChildren()) do
				if not (child and child:FindFirstChild("Humanoid")) then
					continue
				end

				local v4 = v3[child]
				v3[child] = nil

				if v4 then
					StatModifierManager.RemoveSpeedModifiers(child, v4)
				end

				if not (v2[child] or v3[child]) then
					BuffIndicator.clear(child, "GourdySugarRush")
				end
			end
		end

		flag2 = false
	end)
	table.insert(threads, thread)
end

function GourdyGlobalBoosts.CleanupAllBoosts()
	for _, v4 in ipairs(threads) do
		if v4 then
			task.cancel(v4)
		end
	end

	threads = {}
	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		for _, child in pairs(inGamePlayers:GetChildren()) do
			if not (child and child:FindFirstChild("Humanoid")) then
				continue
			end

			if flag then
				local v4 = v2[child]
				v2[child] = nil

				if v4 then
					StatModifierManager.RemoveSpeedModifiers(child, v4)
				end

				if not (v2[child] or v3[child]) then
					BuffIndicator.clear(child, "GourdySugarRush")
				end
			end

			if not flag2 then
				continue
			end

			local v4 = v3[child]
			v3[child] = nil

			if v4 then
				StatModifierManager.RemoveSpeedModifiers(child, v4)
			end

			if not (v2[child] or v3[child]) then
				BuffIndicator.clear(child, "GourdySugarRush")
			end
		end
	end

	flag = false
	flag2 = false
	v2 = {}
	v3 = {}
end

function GourdyGlobalBoosts.GetStatus()
	local count = 0

	for _ in pairs(v) do
		count += 1
	end

	local count2 = 0

	for _ in pairs(v2) do
		count2 += 1
	end

	local count3 = 0

	for _ in pairs(v3) do
		count3 += 1
	end

	return {
		registeredGourdyPlayers = count,
		hasAliveGourdy = hasAliveGourdy(),
		elevatorBoostActive = flag,
		panicBoostActive = flag2,
		elevatorBoostedPlayers = count2,
		panicBoostedPlayers = count3
	}
end

return GourdyGlobalBoosts