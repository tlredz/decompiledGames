local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local BuffIndicator = require(ReplicatedStorage.Modules.Gameplay.BuffIndicator)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local isStudio = RunService:IsStudio()

local function debugLog(...)
	if isStudio then
		print("[RibeccaEmpowered]", ...)
	end
end

local function timedOptions(options)
	local result = {
		category = "ability",
		duration = 10
	}

	for k, v in pairs(options or {}) do
		result[k] = v
	end

	return result
end

local v = {
	{
		key = "Speed",
		text = "Speed +10%",
		particles = "Speed",
		apply = function(p)
			local v2 = StatModifierManager.ApplySpeedModifiers(p, 1.1, "Ribecca Empowered", (timedOptions({
				antiCheat = true
			})))
			return v2.speedModifierId ~= nil and v2.runSpeedModifierId ~= nil
		end
	},
	{
		key = "Stealth",
		text = "Stealth +10%",
		particles = "Stealth",
		apply = function(p)
			return StatModifierManager.ApplyModifier(p, "StealthModifier", 1.1, "Ribecca Empowered", (timedOptions())) ~= nil
		end
	},
	{
		key = "DecodeSpeed",
		text = "Extraction Speed +10%",
		particles = "DecodeSpeed",
		apply = function(p)
			return StatModifierManager.ApplyModifier(
				p,
				"DecodeSpeedModifier",
				1.1,
				"Ribecca Empowered",
				(timedOptions())
			) ~= nil
		end
	},
	{
		key = "StaminaRegen",
		text = "Stamina Regeneration +10%",
		particles = "Stamina",
		apply = function(p)
			return StatModifierManager.ApplyStaminaRegenModifier(p, 1.1, "Ribecca Empowered", (timedOptions())) ~= nil
		end
	},
	{
		key = "SkillCheck",
		text = "Skill Check Window and Chance +10%",
		particles = "SkillCheck",
		apply = function(p)
			local v2 = StatModifierManager.ApplyModifier(p, "BoundarySize", 1.1, "Ribecca Empowered", (timedOptions()))
			local v3 = StatModifierManager.ApplyAdditiveSkillCheckChance(p, 10, "Ribecca Empowered", (timedOptions()))
			return v2 ~= nil and v3 ~= nil
		end
	}
}

local function attachParticles(instance, childName)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local buffParticles = parts and parts:FindFirstChild("BuffParticles")
	local child = buffParticles and buffParticles:FindFirstChild(childName)

	if not (humanoidRootPart and child) then
		debugLog("no BuffParticles set", childName)
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "RibeccaEmpoweredParticle"
	attachment.Parent = humanoidRootPart

	for _, childName2 in ipairs({ "BuffParticle", "Glow" }) do
		local child2 = child:FindFirstChild(childName2)

		if not child2 then
			continue
		end

		local clone = child2:Clone()
		clone.Parent = attachment
		clone.Enabled = true
	end

	task.delay(10, function()
		for _, emitter in ipairs(attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
	Debris:AddItem(attachment, 11)
end

return {
	TryGrant = function(instance, value)
		if not (RunService:IsServer() and TowerLUT:HasPassive(instance, "Ribecca")) then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local ribeccaEmpoweredExpiresAt = instance:GetAttribute("RibeccaEmpoweredExpiresAt")

		if type(ribeccaEmpoweredExpiresAt) == "number" and serverTimeNow < ribeccaEmpoweredExpiresAt then
			if instance:GetAttribute("RibeccaEmpoweredSwallowLogged") ~= ribeccaEmpoweredExpiresAt then
				instance:SetAttribute("RibeccaEmpoweredSwallowLogged", ribeccaEmpoweredExpiresAt)
				debugLog(string.format(
					"%s shrugged off %s, no new buff (%s still active, %.1fs left)",
					instance.Name,
					tostring(value or "debuff"),
					tostring(instance:GetAttribute("RibeccaEmpoweredBuff")),
					ribeccaEmpoweredExpiresAt - serverTimeNow
				))
			end
		else
			local v2 = v[math.random(1, #v)]
			local success, result = pcall(v2.apply, instance)

			if not (success and result) then
				warn(
					"[RibeccaEmpowered] failed to apply",
					v2.key,
					"to",
					instance.Name,
					success and "(stat missing)" or result
				)
				return
			end

			local v3 = serverTimeNow + 10
			instance:SetAttribute("RibeccaEmpoweredExpiresAt", v3)
			instance:SetAttribute("RibeccaEmpoweredBuff", v2.key)
			task.delay(10, function()
				if instance.Parent and instance:GetAttribute("RibeccaEmpoweredExpiresAt") == v3 then
					instance:SetAttribute("RibeccaEmpoweredBuff", nil)
				end
			end)
			BuffIndicator.raise(instance, "RibeccaEmpowered" .. v2.key, 10)
			BuffIndicator.tell(
				instance,
				string.format("Ribecca feels empowered! %s for %s!", v2.text, BuffIndicator.seconds(10))
			)
			pcall(attachParticles, instance, v2.particles)
			local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
			debugLog(string.format(
				"%s shrugged off %s -> %s for %ds",
				playerFromCharacter and playerFromCharacter.Name or instance.Name,
				tostring(value or "debuff"),
				v2.key,
				10
			))
			return true
		end
	end
}