local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Teams")
game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = nil
local v2 = nil
local v3 = require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
local showdownDisableInvis = ReplicatedStorage2.Remotes.ShowdownDisableInvis
local Pulse = {
	AbilityName = "Pulse",
	AbilityCooldown = 30,
	CanUseAbility = function(_, instance)
		if not instance.PrimaryPart or instance:GetAttribute("PULSED") and not instance:GetAttribute("teamVIP") then
			return false
		end

		return not instance:GetAttribute("AbilityCooldown")
	end
}

function Pulse:RegisterCooldown(instance, _: number)
	instance:SetAttribute("AbilityCooldown", true)
	task.delay(Pulse.AbilityCooldown, function()
		if instance:IsDescendantOf(workspace) then
			instance:SetAttribute("AbilityCooldown", nil)
		end
	end)
end

function Pulse.ServerInit(_, p, p2: number, flag: boolean)
	if not v then
		v = require3(ServerScriptService.Game.CoreGameModules.MapManager)
	end

	if not v2 then
		v2 = require3(ServerScriptService.Game.Services.AbilityService)
	end

	if not flag then
		Pulse:RegisterCooldown(p, p2)
	end
end

function Pulse.ServerStart(_, instance, p: number)
	local modeState = v.getModeState()

	if not modeState then
		return
	end

	local playerFromCharacterInMatch = v.getPlayerFromCharacterInMatch(instance)

	if not playerFromCharacterInMatch then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local playerTeam = v3.GetPlayerTeam(playerFromCharacterInMatch)
	local cFrame = humanoidRootPart.CFrame
	local v4 = p == 2
	local v5 = p * 3 + 10
	local v6 = {}

	for _, child in ipairs(workspace.Alive:GetChildren()) do
		if child == instance then
			continue
		end

		local playerFromCharacterInMatch2 = v.getPlayerFromCharacterInMatch(child)

		if playerFromCharacterInMatch2 and (not (#modeState.teams >= 2) or v3.GetPlayerTeam(playerFromCharacterInMatch2) ~= playerTeam) then
			table.insert(v6, { child, child:GetPivot() })
		end
	end

	ReplicatedStorage2.Remotes.PulseFX:FireAllClients(humanoidRootPart, v4, 70.4, v6, v5)
	task.delay(0.5, function()
		for _, v7 in ipairs(v6) do
			local v8 = v7[1]

			if (v7[2].Position - cFrame.Position).Magnitude > 70.4 or v8:GetAttribute("Dead") or v8:GetAttribute("DoNotTarget") or v8:GetAttribute("IsFrozen") then
				continue
			end

			disableCharacter(v8, v5)
		end
	end)
end

function disableCharacter(instance, duration: number)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		ReplicatedStorage2.Remotes.ClientPulse:FireClient(playerFromCharacter, duration)
	end

	v2:BlockAbilities(instance, "Pulse")
	instance:SetAttribute("CANCEL_ONGOING_PLS", true)
	task.delay(duration, function()
		instance:SetAttribute("CANCEL_ONGOING_PLS", nil)
		v2:UnblockAbilities(instance, "Pulse")
	end)

	if not playerFromCharacter then
		return
	end

	disablePlayerAbilityState(playerFromCharacter)
	showdownDisableInvis:Fire(playerFromCharacter, playerFromCharacter.Upgrades.Invisibility.Value >= 2)
	task.spawn(function()
		local currentBall = v.getCurrentBall()

		if currentBall then
			if currentBall then
				currentBall:changeInfinityStatus(playerFromCharacter, false)
				instance:SetAttribute("CANCEL_ONGOING_PLS", true)
				currentBall:changeInvisStatus(playerFromCharacter, false)
				local character = playerFromCharacter.Character

				if character then
					character:SetAttribute("Invisible", nil)
				end

				currentBall:changeForcefieldStatus(playerFromCharacter, false)
				currentBall.ConfidentTarget = nil

				if character then
					character:SetAttribute("IS_CONFIDENT", nil)
				end
			end
		else
			while true do
				v.getCurrentBall()
				task.wait()
			end
		end
	end)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local shield = humanoidRootPart:FindFirstChild("Shield")

		if shield then
			shield:Destroy()
		end

		local maxShield = humanoidRootPart:FindFirstChild("MaxShield")

		if maxShield then
			maxShield:Destroy()
		end
	end
end

function disablePlayerAbilityState(player)
	local character = player.Character

	if character then
		character:SetAttribute("Ability", nil)
		character:SetAttribute("AbilityActive", nil)
	end
end

return Pulse