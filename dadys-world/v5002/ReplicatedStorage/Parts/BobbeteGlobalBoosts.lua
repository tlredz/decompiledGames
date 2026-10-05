local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local BobbeteGlobalBoosts = {
	Counts = {},
	HasBuff = {},
	ModifierIds = {},
	ActiveParticles = {}
}

local function applyBuffsOnce(instance)
	if BobbeteGlobalBoosts.HasBuff[instance] or not (instance and instance.Parent) then
		return
	end

	local staminaRegen = StatModifierManager.ApplyStaminaRegenModifier(instance, 1.5, "BobetteBoost", {
		category = "ability"
	})
	local speed2 = StatModifierManager.ApplySpeedModifiers(instance, 1.25, "BobetteBoost", {
		category = "ability"
	})
	BobbeteGlobalBoosts.ModifierIds[instance] = {
		staminaRegen = staminaRegen,
		speed = speed2
	}
	BobbeteGlobalBoosts.HasBuff[instance] = true

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance.HumanoidRootPart
		local attachment = Instance.new("Attachment")
		attachment.Name = "BobetteBuffParticle"
		attachment.Parent = humanoidRootPart
		local speed = game.ReplicatedStorage:FindFirstChild("Parts") and game.ReplicatedStorage.Parts:FindFirstChild("BuffParticles") and game.ReplicatedStorage.Parts.BuffParticles:FindFirstChild("Speed")

		if speed then
			local clone = speed.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = speed.Glow:Clone()
			clone2.Parent = attachment
			clone2.Enabled = true
		end

		BobbeteGlobalBoosts.ActiveParticles[instance] = attachment
	end
end

local function removeBuffsOnce(p)
	if not BobbeteGlobalBoosts.HasBuff[p] then
		return
	end

	local modifierId = BobbeteGlobalBoosts.ModifierIds[p]
	BobbeteGlobalBoosts.ModifierIds[p] = nil
	BobbeteGlobalBoosts.HasBuff[p] = nil

	if p and p.Parent and modifierId then
		pcall(function()
			if modifierId.staminaRegen then
				StatModifierManager.RemoveStaminaRegenModifier(p, modifierId.staminaRegen)
			end

			if modifierId.speed then
				StatModifierManager.RemoveSpeedModifiers(p, modifierId.speed)
			end
		end)
	end

	if BobbeteGlobalBoosts.ActiveParticles[p] then
		local activeParticle = BobbeteGlobalBoosts.ActiveParticles[p]
		pcall(function()
			for _, emitter in ipairs(activeParticle:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = false
				emitter:Clear()
			end

			activeParticle:Destroy()
		end)
		BobbeteGlobalBoosts.ActiveParticles[p] = nil
	end
end

function BobbeteGlobalBoosts.AddBoost(p)
	BobbeteGlobalBoosts.Counts[p] = (BobbeteGlobalBoosts.Counts[p] or 0) + 1

	if BobbeteGlobalBoosts.Counts[p] == 1 then
		applyBuffsOnce(p)
	end
end

function BobbeteGlobalBoosts.RemoveBoost(p)
	local count = BobbeteGlobalBoosts.Counts[p]

	if not count or count <= 0 then
		return
	end

	BobbeteGlobalBoosts.Counts[p] = count - 1

	if BobbeteGlobalBoosts.Counts[p] == 0 then
		BobbeteGlobalBoosts.Counts[p] = nil
		removeBuffsOnce(p)
	end
end

function BobbeteGlobalBoosts.CleanupCharacter(p)
	removeBuffsOnce(p)
	BobbeteGlobalBoosts.Counts[p] = nil
	BobbeteGlobalBoosts.HasBuff[p] = nil
	BobbeteGlobalBoosts.ModifierIds[p] = nil

	if BobbeteGlobalBoosts.ActiveParticles[p] then
		pcall(function()
			BobbeteGlobalBoosts.ActiveParticles[p]:Destroy()
		end)
		BobbeteGlobalBoosts.ActiveParticles[p] = nil
	end
end

return BobbeteGlobalBoosts