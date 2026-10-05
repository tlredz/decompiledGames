local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local LuckyCoin = {
	Name = "Lucky Coin",
	Icon = "rbxassetid://129353401139449",
	Rarity = "Common",
	Description = "Gain a 12% boost to a random stat each Floor. Prior Floor's effect wears off when entering a new floor. As Gigi, removes Common items from her Ability's pool.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
LuckyCoin.Requirement1 = { "Coin", LuckyCoin.Cost }
local v = {}

function LuckyCoin.ApplyTrinket(instance)
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("SkillCheckChance")

	if not v[instance] then
		v[instance] = {}
	end

	local function togglestats()
		local v2 = {
			"Speed",
			"Stamina",
			"SkillCheck",
			"DecodeSpeed",
			"Stealth"
		}
		local v3 = v2[math.random(1, #v2)]

		if v[instance].currentModifiers then
			local v4 = v[instance]

			if v4.statType == "Speed" then
				StatModifierManager.RemoveSpeedModifiers(instance, v4.currentModifiers)
			elseif v4.statType == "Stamina" then
				StatModifierManager.RemoveModifier(instance, "StaminaModifier", v4.currentModifiers.staminaModifierId)
				local currentStamina = stats:FindFirstChild("CurrentStamina")

				if currentStamina then
					currentStamina.Value /= 1.12
				end
			elseif v4.statType == "SkillCheck" then
				StatModifierManager.RemoveModifier(instance, "BoundarySize", v4.currentModifiers.boundaryModifierId)

				if v4.currentModifiers.skillCheckModId then
					StatModifierManager.RemoveAdditiveSkillCheckChance(instance, v4.currentModifiers.skillCheckModId)
				end
			elseif v4.statType == "DecodeSpeed" then
				StatModifierManager.RemoveModifier(
					instance,
					"DecodeSpeedModifier",
					v4.currentModifiers.decodeModifierId
				)
			elseif v4.statType == "Stealth" then
				StatModifierManager.RemoveModifier(instance, "StealthModifier", v4.currentModifiers.stealthModifierId)
			end
		end

		if v3 == "Speed" then
			local currentModifiers = StatModifierManager.ApplySpeedModifiers(instance, 1.12, "LuckyCoin", {
				category = "trinket"
			})
			v[instance].currentModifiers = currentModifiers
			v[instance].statType = "Speed"
		elseif v3 == "Stamina" then
			local staminaModifierId = StatModifierManager.ApplyModifier(
				instance,
				"StaminaModifier",
				1.12,
				"LuckyCoin",
				{
					category = "trinket"
				}
			)
			local currentStamina = stats:FindFirstChild("CurrentStamina")

			if currentStamina then
				currentStamina.Value *= 1.12
			end

			v[instance].currentModifiers = {
				staminaModifierId = staminaModifierId
			}
			v[instance].statType = "Stamina"
		elseif v3 == "SkillCheck" then
			local skillCheckModId = StatModifierManager.ApplyAdditiveSkillCheckChance(instance, 12, "LuckyCoin")
			local boundaryModifierId = StatModifierManager.ApplyModifier(instance, "BoundarySize", 1.12, "LuckyCoin", {
				category = "trinket"
			})
			v[instance].currentModifiers = {
				boundaryModifierId = boundaryModifierId,
				skillCheckModId = skillCheckModId
			}
			v[instance].statType = "SkillCheck"
		elseif v3 == "DecodeSpeed" then
			local decodeModifierId = StatModifierManager.ApplyModifier(
				instance,
				"DecodeSpeedModifier",
				1.12,
				"LuckyCoin",
				{
					category = "trinket"
				}
			)
			v[instance].currentModifiers = {
				decodeModifierId = decodeModifierId
			}
			v[instance].statType = "DecodeSpeed"
		elseif v3 == "Stealth" then
			local stealthModifierId = StatModifierManager.ApplyModifier(
				instance,
				"StealthModifier",
				1.12,
				"LuckyCoin",
				{
					category = "trinket"
				}
			)
			v[instance].currentModifiers = {
				stealthModifierId = stealthModifierId
			}
			v[instance].statType = "Stealth"
		end
	end

	togglestats()
	workspace.Info.Floor.Changed:Connect(togglestats)
end

function LuckyCoin.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if v[instance] and v[instance].currentModifiers then
		local stats = instance:FindFirstChild("Stats")
		local v2 = v[instance]

		if v2.statType == "Speed" then
			StatModifierManager.RemoveSpeedModifiers(instance, v2.currentModifiers)
		elseif v2.statType == "Stamina" then
			StatModifierManager.RemoveModifier(instance, "StaminaModifier", v2.currentModifiers.staminaModifierId)
			local currentStamina = stats and stats:FindFirstChild("CurrentStamina")

			if currentStamina then
				currentStamina.Value /= 1.12
			end
		elseif v2.statType == "SkillCheck" then
			StatModifierManager.RemoveModifier(instance, "BoundarySize", v2.currentModifiers.boundaryModifierId)

			if v2.currentModifiers.skillCheckModId then
				StatModifierManager.RemoveAdditiveSkillCheckChance(instance, v2.currentModifiers.skillCheckModId)
			end
		elseif v2.statType == "DecodeSpeed" then
			StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v2.currentModifiers.decodeModifierId)
		elseif v2.statType == "Stealth" then
			StatModifierManager.RemoveModifier(instance, "StealthModifier", v2.currentModifiers.stealthModifierId)
		end

		v[instance] = nil
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		return "Slot1"
	end

	if trinket2.Value ~= script.Name then
		return "CantRemove"
	end

	trinket2.Value = "None"
	return "Slot2"
end

return LuckyCoin