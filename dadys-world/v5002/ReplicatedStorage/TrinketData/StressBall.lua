local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local StressBall = {
	Name = "Stress Ball",
	Icon = "rbxassetid://86691053721590",
	Rarity = "Common",
	Description = "Increases your Extraction Speed by 5% upon completion of a Skill Check. Effect lasts for " .. 15 .. " seconds and stacks.",
	TrinketType = "Passive",
	TrinketState = "DecodeSpeed",
	MonsterTrinket = true,
	Cost = 350
}
StressBall.Requirement1 = { "Coin", StressBall.Cost }
StressBall.SkillCheckCompleteEvent = true

function StressBall.ApplyTrinket(_) end

local function updateModifier(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	if v2.modId then
		StatModifierManager.RemoveModifier(p, "DecodeSpeedModifier", v2.modId)
		v2.modId = nil
	end

	if v2.stackCount > 0 then
		local v3 = 1 + 0.05 * v2.stackCount
		v2.modId = StatModifierManager.ApplyModifier(p, "DecodeSpeedModifier", v3, "StressBall", {
			category = "trinket"
		})
	else
		v[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeStack(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v2.stackCount -= 1
	updateModifier(p)
end

function StressBall.RemoveTrinket(instance)
	local trinkets = instance:FindFirstChild("Trinkets")

	if not trinkets then
		return "CantRemove"
	end

	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	local v2 = v[instance]

	if v2 then
		if v2.modId then
			StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v2.modId)
		end

		for _, expireThread in v2.expireThreads do
			task.cancel(expireThread)
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

function StressBall.TriggerSkillCheckCompleteEvent(_, _, p)
	local value = p.Value

	if not value then
		return
	end

	if value:IsA("Player") then
		value = value.Character or value
	end

	if not (value and value.Parent) then
		return
	end

	if not v[value] then
		v[value] = {
			modId = nil,
			stackCount = 0,
			expireThreads = {}
		}
	end

	local v2 = v[value]
	v2.stackCount += 1
	updateModifier(value)
	local thread = nil
	thread = task.delay(15, function()
		local v3 = v[value]

		if v3 then
			for k, expireThread in v3.expireThreads do
				if expireThread ~= thread then
					continue
				end

				table.remove(v3.expireThreads, k)
				break
			end
		end

		removeStack(value) -- equivalent call inferred; original call site unknown
	end)
	table.insert(v2.expireThreads, thread)
end

return StressBall