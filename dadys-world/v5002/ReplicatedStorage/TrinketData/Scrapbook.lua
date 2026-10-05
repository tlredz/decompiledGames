local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local Scrapbook = {}
Scrapbook.Name = "Scrapbook"
Scrapbook.Icon = "rbxassetid://134423524467051"
Scrapbook.Description = "Decreases Stealth by 5%."
Scrapbook.Rarity = "Common"
Scrapbook.TrinketType = "Passive"
Scrapbook.Cost = 200
Scrapbook.Requirement1 = { "Coin", 200 }

function Scrapbook.ApplyTrinket(instance, _)
	instance:SetAttribute(
		"ScrapbookModifierId",
		(StatModifierManager.ApplyModifier(instance, "StealthModifier", 0.95, "Scrapbook_Trinket", {
			category = "trinket"
		}))
	)
end

function Scrapbook.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeModifier()
		local scrapbookModifierId = instance:GetAttribute("ScrapbookModifierId")

		if scrapbookModifierId then
			StatModifierManager.RemoveModifier(instance, "StealthModifier", scrapbookModifierId)
			instance:SetAttribute("ScrapbookModifierId", nil)
		end
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		removeModifier() -- equivalent call inferred; original call site unknown
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		removeModifier() -- equivalent call inferred; original call site unknown
		return "Slot2"
	end
end

return Scrapbook