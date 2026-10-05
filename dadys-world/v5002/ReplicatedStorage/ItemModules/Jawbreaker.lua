local Jawbreaker = {
	Name = "Jawbreaker",
	PointCost = 58,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Rare",
	Icon = "rbxassetid://128185500990835",
	Description = "Use this item to gain a random 50% effect for 20 seconds.",
	ItemDuration = 20
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function Jawbreaker.UseItem(instance, p, p2)
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("SkillCheckChance")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local decoding = instance:WaitForChild("Decoding")
	local itemDuration = Jawbreaker.ItemDuration

	if p2 and p2 > 0 then
		itemDuration += p2
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		Audio:Play("Sounds.Misc.UseSound", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
	end

	local v2 = decoding.Value == nil and {
		"Speed",
		"Stamina",
		"Speed",
		"Stamina",
		"SkillCheck",
		"DecodeSpeed",
		"Stealth",
		"Stealth"
	} or {
		"Speed",
		"Stamina",
		"SkillCheck",
		"DecodeSpeed",
		"SkillCheck",
		"DecodeSpeed",
		"Stealth"
	}
	local v3 = v2[math.random(1, #v2)]
	local v4 = ({
		Speed = "Speed +50%",
		Stamina = "Max Stamina +50%",
		SkillCheck = "Skill Check Window and Chance +50%",
		DecodeSpeed = "Extraction Speed +50%",
		Stealth = "Stealth +50%"
	})[v3]
	BuffIndicator.raise(instance, "ItemJawbreaker", itemDuration)

	if v4 then
		BuffIndicator.tell(instance, "Jawbreaker! " .. v4 .. " for " .. BuffIndicator.seconds(itemDuration) .. "!")
	end

	if v3 == "Speed" then
		local v5 = StatModifierManager.ApplySpeedModifiers(instance, 1.5, "Jawbreaker", {
			category = "item",
			antiCheat = true
		})
		task.delay(itemDuration, function()
			if instance and instance.Parent ~= nil then
				StatModifierManager.RemoveSpeedModifiers(instance, v5)
			end
		end)
	elseif v3 == "Stamina" then
		local v5 = {
			staminaModifierId = StatModifierManager.ApplyModifier(instance, "StaminaModifier", 1.5, "Jawbreaker", {
				category = "item"
			})
		}
		local currentStamina = stats:FindFirstChild("CurrentStamina")

		if currentStamina then
			currentStamina.Value *= 1.5
			v5.currentStaminaBoosted = true
		end

		task.delay(itemDuration, function()
			if instance and instance.Parent ~= nil then
				if v5.staminaModifierId then
					StatModifierManager.RemoveModifier(instance, "StaminaModifier", v5.staminaModifierId)
				end

				if v5.currentStaminaBoosted and currentStamina then
					currentStamina.Value /= 1.5
				end
			end
		end)
	else
		local v5

		if v3 == "SkillCheck" then
			v5 = StatModifierManager.ApplyModifier(instance, "BoundarySize", 1.5, "Jawbreaker", {
				category = "item"
			})
			local v6 = StatModifierManager.ApplyAdditiveSkillCheckChance(instance, 50, "Jawbreaker")
			task.delay(itemDuration, function()
				if instance and instance.Parent ~= nil then
					StatModifierManager.RemoveModifier(instance, "BoundarySize", v5)
					StatModifierManager.RemoveAdditiveSkillCheckChance(instance, v6)
				end
			end)
		elseif v3 == "DecodeSpeed" then
			v5 = StatModifierManager.ApplyModifier(instance, "DecodeSpeedModifier", 1.5, "Jawbreaker", {
				category = "item"
			})
			task.delay(itemDuration, function()
				if instance and instance.Parent ~= nil then
					StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v5)
				end
			end)
		elseif v3 == "Stealth" then
			v5 = StatModifierManager.ApplyModifier(instance, "StealthModifier", 1.5, "Jawbreaker", {
				category = "item"
			})
			task.delay(itemDuration, function()
				if instance and instance.Parent ~= nil then
					StatModifierManager.RemoveModifier(instance, "StealthModifier", v5)
				end
			end)
		end
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "BuffParticle"
	attachment.Parent = humanoidRootPart
	local clone = game.ReplicatedStorage.Parts.BuffParticles[v3].BuffParticle:Clone()
	clone.Parent = attachment
	clone.Enabled = true
	local clone2 = game.ReplicatedStorage.Parts.BuffParticles[v3].Glow:Clone()
	clone2.Parent = attachment
	clone2.Enabled = true
	Debris:AddItem(clone, itemDuration + 1)
	Debris:AddItem(clone2, itemDuration + 1)
	Debris:AddItem(attachment, itemDuration + 1)
	task.delay(itemDuration, function()
		if instance and instance.Parent ~= nil and attachment then
			clone.Enabled = false
			clone2.Enabled = false
		end
	end)
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 5
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return Jawbreaker