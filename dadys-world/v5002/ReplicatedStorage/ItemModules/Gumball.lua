local Gumball = {
	Name = "Gumballs",
	PointCost = 20,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Common",
	Icon = "rbxassetid://17728443666",
	Description = "Use this item to gain a random 10% effect for 5 seconds. Has 3 uses.",
	HasCharges = true,
	Charges = 3,
	ItemDuration = 5
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function Gumball.UseItem(instance, instance2, p)
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("SkillCheckChance")
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance2:WaitForChild("Charges")
	local current = instance2:WaitForChild("Current")
	local itemDuration = Gumball.ItemDuration

	if p and p > 0 then
		itemDuration += p
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		Audio:Play("Sounds.Items.Gumball.UseSound", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
	end

	local v2 = {
		"Speed",
		"Stamina",
		"SkillCheck",
		"DecodeSpeed",
		"Stealth"
	}
	local v3 = v2[math.random(1, #v2)]
	local v4 = ({
		Speed = "Speed +10%",
		Stamina = "Max Stamina +10%",
		SkillCheck = "Skill Check Window and Chance +10%",
		DecodeSpeed = "Extraction Speed +10%",
		Stealth = "Stealth +10%"
	})[v3]
	BuffIndicator.raise(instance, "ItemGumball", itemDuration)

	if v4 then
		BuffIndicator.tell(instance, "Gumballs! " .. v4 .. " for " .. BuffIndicator.seconds(itemDuration) .. "!")
	end

	if v3 == "Speed" then
		local v5 = StatModifierManager.ApplySpeedModifiers(instance, 1.1, "Gumball", {
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
			staminaModifierId = StatModifierManager.ApplyModifier(instance, "StaminaModifier", 1.1, "Gumball", {
				category = "item"
			})
		}
		local currentStamina = stats:FindFirstChild("CurrentStamina")

		if currentStamina then
			currentStamina.Value *= 1.1
			v5.currentStaminaBoosted = true
		end

		task.delay(itemDuration, function()
			if instance and instance.Parent ~= nil then
				if v5.staminaModifierId then
					StatModifierManager.RemoveModifier(instance, "StaminaModifier", v5.staminaModifierId)
				end

				if v5.currentStaminaBoosted and currentStamina then
					currentStamina.Value /= 1.1
				end
			end
		end)
	else
		local v5

		if v3 == "SkillCheck" then
			v5 = StatModifierManager.ApplyModifier(instance, "BoundarySize", 1.1, "Gumball", {
				category = "item"
			})
			local v6 = StatModifierManager.ApplyAdditiveSkillCheckChance(instance, 10, "Gumball")
			task.delay(itemDuration, function()
				if instance and instance.Parent ~= nil then
					StatModifierManager.RemoveModifier(instance, "BoundarySize", v5)
					StatModifierManager.RemoveAdditiveSkillCheckChance(instance, v6)
				end
			end)
		elseif v3 == "DecodeSpeed" then
			v5 = StatModifierManager.ApplyModifier(instance, "DecodeSpeedModifier", 1.1, "Gumball", {
				category = "item"
			})
			task.delay(itemDuration, function()
				if instance and instance.Parent ~= nil then
					StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v5)
				end
			end)
		elseif v3 == "Stealth" then
			v5 = StatModifierManager.ApplyModifier(instance, "StealthModifier", 1.1, "Gumball", {
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
	current.Value -= 1

	if current.Value <= 0 then
		instance2.Value = "None"
		local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

		if child then
			local survivalPoints = child:WaitForChild("SurvivalPoints")
			survivalPoints.Value += 2
		end
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return Gumball