local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Shared.UseBall2)
local remoteEvent = v:RemoteEvent("ReplicateBotAbilityUse")
local v3 = {}
local v4 = nil

for _, moduleScript in ipairs((script:WaitForChild("Abilities"):GetChildren())) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local success, result = pcall(require3, moduleScript)

	if success then
		table.insert(v3, result)
	end
end

local BotAbilities = {}

function BotAbilities.Init(_)
	if RunService:IsServer() then
		v4 = require3(ServerScriptService.Game.CoreGameModules.MapManager)
	end

	if RunService:IsClient() then
		remoteEvent.OnClientEvent:Connect(function(...)
			local v5, v6, v7, v8 = ...
			local ability = BotAbilities:GetAbility(v7)

			if not ability then
				return
			end

			local character = v6.Character

			if not character then
				return
			end

			if v5 == "ClientInit" and ability.ClientInit then
				ability.ClientInit(ability, character, v8)
			end

			if v5 == "ClientStart" and ability.ClientStart then
				ability.ClientStart(ability, character, v8)
			end
		end)
	end
end

function BotAbilities.GetSupportedAbilities(_)
	local abilityNames = {}

	for _, v5 in ipairs(v3) do
		table.insert(abilityNames, v5.AbilityName)
	end

	return abilityNames
end

function BotAbilities.UseAbility(_, ...)
	local v5, v6, v7, v8 = ...

	if typeof(v5) ~= "table" then
		error("Cannot use method \"UseAbility\" on non-VirtualPlayer.")
	end

	if v2() then
		warn("[BotAbilities]: Cannot use Ball1 Abilities wih Ball2 enabled!")
		return false
	end

	local character = v5.Character

	if not character or (character:GetAttribute("Dead") or character:IsDescendantOf(workspace.Dead)) or not v4.getPlayerFromCharacterInMatch(v5.Character) then
		return false
	end

	local ability = BotAbilities:GetAbility(v6)

	if not (ability and ability:CanUseAbility(character)) then
		return false
	end

	if ability.ServerInit then
		ability:ServerInit(character, v7, v8)
	end

	if ability.ClientInit then
		remoteEvent:FireAllClients("ClientInit", ...)
	end

	if ability.ServerStart then
		task.spawn(ability.ServerStart, ability, character, v7, v8)
	end

	if ability.ClientStart then
		remoteEvent:FireAllClients("ClientStart", ...)
	end

	return true
end

function BotAbilities:GetAbility(p: string)
	for _, v5 in ipairs(v3) do
		if v5.AbilityName == p then
			return v5
		end
	end
end

return BotAbilities