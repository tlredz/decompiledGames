local PassiveAbilityManager = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local v = {}

function PassiveAbilityManager.InitializePassive(p, instance, childName)
	if not (p and instance and childName) then
		warn("PassiveAbilityManager: Invalid parameters for InitializePassive")
		return
	end

	local passiveAbilityModules = ReplicatedStorage:FindFirstChild("PassiveAbilityModules")

	if not passiveAbilityModules then
		warn("PassiveAbilityManager: PassiveAbilityModules folder not found")
		return
	end

	local child = passiveAbilityModules:FindFirstChild(childName)

	if not child then
		warn("PassiveAbilityManager: Passive ability module not found:", childName)
		return
	end

	local success, result = pcall(require, child)

	if not success then
		warn("PassiveAbilityManager: Failed to load passive module:", childName, result)
		return
	end

	if type(result.Initialize) ~= "function" then
		warn("PassiveAbilityManager: Module missing Initialize function:", childName)
		return
	end

	if not v[p] then
		v[p] = {}
	end

	if v[p][childName] then
		PassiveAbilityManager.CleanupPassive(p, childName)
	end

	local success2, result2 = pcall(function()
		return result.Initialize(instance, p)
	end)

	if not success2 then
		warn("PassiveAbilityManager: Failed to initialize passive:", childName, result2)
		return
	end

	v[p][childName] = {
		module = result,
		cleanup = result2,
		character = instance
	}
	local humanoid = instance:FindFirstChild("Humanoid")

	if humanoid then
		local diedConnection = humanoid.Died:Connect(function()
			PassiveAbilityManager.CleanupPassive(p, childName)
		end)
		v[p][childName].diedConnection = diedConnection
	end

	local ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			PassiveAbilityManager.CleanupPassive(p, childName)
		end
	end)
	v[p][childName].ancestryConnection = ancestryChangedConnection
end

function PassiveAbilityManager.CleanupPassive(p, p2)
	if not (v[p] and v[p][p2]) then
		return
	end

	local v2 = v[p][p2]

	if v2.diedConnection then
		v2.diedConnection:Disconnect()
	end

	if v2.ancestryConnection then
		v2.ancestryConnection:Disconnect()
	end

	if v2.cleanup and type(v2.cleanup) == "function" then
		local success, result = pcall(v2.cleanup)

		if not success then
			warn("PassiveAbilityManager: Cleanup function error for", p2, result)
		end
	end

	if v2.module and type(v2.module.Cleanup) == "function" then
		local success, result = pcall(v2.module.Cleanup, v2.character, p)

		if not success then
			warn("PassiveAbilityManager: Module cleanup error for", p2, result)
		end
	end

	v[p][p2] = nil
end

function PassiveAbilityManager.CleanupAllPassives(p)
	if not v[p] then
		return
	end

	for k, _ in pairs(v[p]) do
		PassiveAbilityManager.CleanupPassive(p, k)
	end

	v[p] = nil
end

function PassiveAbilityManager.GetActivePassives(p)
	if not v[p] then
		return {}
	end

	local result = {}

	for k, _ in pairs(v[p]) do
		table.insert(result, k)
	end

	return result
end

function PassiveAbilityManager.HasPassive(p, p2)
	return v[p] and v[p][p2] ~= nil
end

Players.PlayerRemoving:Connect(function(player)
	PassiveAbilityManager.CleanupAllPassives(player)
end)
Players.PlayerAdded:Connect(function(player)
	player.CharacterRemoving:Connect(function(character)
		local v2 = v[player]

		if not v2 then
			return
		end

		for k, v3 in pairs(v2) do
			if v3.character == character then
				PassiveAbilityManager.CleanupPassive(player, k)
			end
		end
	end)
end)
return PassiveAbilityManager