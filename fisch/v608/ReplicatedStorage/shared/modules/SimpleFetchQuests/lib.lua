local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientRichText = require(ReplicatedStorage.shared.utils.FischUtils.Shared.GradientRichText)

-- equivalent calls inferred from this helper; original call sites unknown
local function arrayIfString(value)
	if typeof(value) == "string" or typeof(value) == "table" and value.__var then
		return { value }
	end

	return value
end

local Lib = {
	CatchFish = function(data)
		local v = data.RequiredAttributes ~= nil
		local v2 = not data.RequiredAttributes and {} or table.clone(data.RequiredAttributes) or {}

		if data.PerfectCatch ~= nil then
			v2.Perfect = data.PerfectCatch
			v = true
		end

		if data.DirectCatch ~= nil then
			v2.Direct = data.DirectCatch
			v = true
		end

		if data.AndReturn ~= nil then
			v2.Return = data.AndReturn
			v = true
		end

		if data.PlayerZones ~= nil then
			v2.Locations = arrayIfString(data.PlayerZones)
			v = true
		end

		if data.FishingZones ~= nil then
			v2.Zones = arrayIfString(data.FishingZones)
			v = true
		end

		if data.EventFlags ~= nil then
			v2.EventFlags = arrayIfString(data.EventFlags)
			v = true
		end

		if data.EventFlagsRequireAll ~= nil then
			v2.AllEventFlags = data.EventFlagsRequireAll
			v = true
		end

		if data.BiteStats ~= nil then
			v2.BiteStats = data.BiteStats
			v = true

			for _, biteStat in data.BiteStats do
				if biteStat[1] == nil and biteStat[2] ~= nil then
					biteStat[1] = -1e999
				end
			end
		end

		if not v then
			v2 = nil
		end

		local requiredAmount = data.RequiredAmount or 1
		local v3 = arrayIfString(data.Fish) -- equivalent call inferred; original call site unknown
		local v4 = arrayIfString(data.Raritites) -- equivalent call inferred; original call site unknown
		local v5 = arrayIfString(data.Rods) -- equivalent call inferred; original call site unknown
		local v6 = arrayIfString(data.Bait) -- equivalent call inferred; original call site unknown
		return {
			"CatchFish",
			requiredAmount,
			v3,
			v4,
			v2,
			v5,
			v6,
			nil,
			arrayIfString(data.EnchantCombos)
		}
	end,
	CatchFishSpear = function(data)
		local v = data.RequiredAttributes ~= nil
		local v2 = not data.RequiredAttributes and {} or table.clone(data.RequiredAttributes) or {}

		if data.PerfectCatch ~= nil then
			v2.Perfect = data.PerfectCatch
			v = true
		end

		if data.DirectCatch ~= nil then
			v2.Direct = data.DirectCatch
			v = true
		end

		if data.AndReturn ~= nil then
			v2.Return = data.AndReturn
			v = true
		end

		if data.PlayerZones ~= nil then
			v2.Locations = arrayIfString(data.PlayerZones)
			v = true
		end

		if data.FishingZones ~= nil then
			v2.Zones = arrayIfString(data.FishingZones)
			v = true
		end

		if data.EventFlags ~= nil then
			v2.EventFlags = arrayIfString(data.EventFlags)
			v = true
		end

		if data.EventFlagsRequireAll ~= nil then
			v2.AllEventFlags = data.EventFlagsRequireAll
			v = true
		end

		if data.BiteStats ~= nil then
			v2.BiteStats = data.BiteStats
			v = true

			for _, biteStat in data.BiteStats do
				if biteStat[1] == nil and biteStat[2] ~= nil then
					biteStat[1] = -1e999
				end
			end
		end

		if not v then
			v2 = nil
		end

		local requiredAmount = data.RequiredAmount or 1
		local v3 = arrayIfString(data.Fish) -- equivalent call inferred; original call site unknown
		local v4 = arrayIfString(data.Raritites) -- equivalent call inferred; original call site unknown
		return {
			"CatchFishWithSpear",
			requiredAmount,
			v3,
			v4,
			v2,
			arrayIfString(data.Spears)
		}
	end,
	CatchFishCage = function(data)
		local v = data.RequiredAttributes ~= nil
		local v2 = not data.RequiredAttributes and {} or table.clone(data.RequiredAttributes) or {}

		if data.DirectCatch ~= nil then
			v2.Direct = data.DirectCatch
			v = true
		end

		if data.AndReturn ~= nil then
			v2.Return = data.AndReturn
			v = true
		end

		if data.PlayerZones ~= nil then
			v2.Locations = arrayIfString(data.PlayerZones)
			v = true
		end

		if data.FishingZones ~= nil then
			v2.Zones = arrayIfString(data.FishingZones)
			v = true
		end

		if data.EventFlags ~= nil then
			v2.EventFlags = arrayIfString(data.EventFlags)
			v = true
		end

		if data.EventFlagsRequireAll ~= nil then
			v2.AllEventFlags = data.EventFlagsRequireAll
			v = true
		end

		if data.BiteStats ~= nil then
			v2.BiteStats = data.BiteStats
			v = true

			for _, biteStat in data.BiteStats do
				if biteStat[1] == nil and biteStat[2] ~= nil then
					biteStat[1] = -1e999
				end
			end
		end

		if not v then
			v2 = nil
		end

		local requiredAmount = data.RequiredAmount or 1
		local v3 = arrayIfString(data.Fish) -- equivalent call inferred; original call site unknown
		return {
			"CatchFishWithCrabCage",
			requiredAmount,
			v3,
			arrayIfString(data.Raritites),
			v2
		}
	end,
	CatchFishAny = function(data)
		local v = data.RequiredAttributes ~= nil
		local v2 = not data.RequiredAttributes and {} or table.clone(data.RequiredAttributes) or {}

		if data.Rods or data.Spear then
			warn(debug.traceback("u cant specify that here mate"))
		end

		if data.PerfectCatch ~= nil then
			v2.Perfect = data.PerfectCatch
			v = true
		end

		if data.DirectCatch ~= nil then
			v2.Direct = data.DirectCatch
			v = true
		end

		if data.AndReturn ~= nil then
			v2.Return = data.AndReturn
			v = true
		end

		if data.PlayerZones ~= nil then
			v2.Locations = arrayIfString(data.PlayerZones)
			v = true
		end

		if data.FishingZones ~= nil then
			v2.Zones = arrayIfString(data.FishingZones)
			v = true
		end

		if data.IgnoreSourceTypes ~= nil then
			v2.IgnoreSourceTypes = arrayIfString(data.IgnoreSourceTypes)
			v = true
		end

		if data.EventFlags ~= nil then
			v2.EventFlags = arrayIfString(data.EventFlags)
			v = true
		end

		if data.EventFlagsRequireAll ~= nil then
			v2.AllEventFlags = data.EventFlagsRequireAll
			v = true
		end

		if data.BiteStats ~= nil then
			v2.BiteStats = data.BiteStats
			v = true

			for _, biteStat in data.BiteStats do
				if biteStat[1] == nil and biteStat[2] ~= nil then
					biteStat[1] = -1e999
				end
			end
		end

		if not v then
			v2 = nil
		end

		local requiredAmount = data.RequiredAmount or 1
		local fish = data.Fish or data.Item
		local v3 = arrayIfString(fish) -- equivalent call inferred; original call site unknown
		return {
			"CatchFishAny",
			requiredAmount,
			v3,
			arrayIfString(data.Raritites),
			v2
		}
	end,
	ObtainItem = function(data)
		local _ = data.RequiredAttributes == nil
		local v = not data.RequiredAttributes and {} or table.clone(data.RequiredAttributes) or {}
		local v2 = {}

		if data.Suffix ~= nil then
			v2.Suffix = data.Suffix
		end

		if data.ForNpc ~= nil then
			v2.Suffix = `{not v2.Suffix and "" or v2.Suffix .. " " or ""}for {data.ForNpc}`
			v2.Return = true
		end

		if data.AndReturn ~= nil then
			v2.Return = data.AndReturn
		end

		local requiredAmount = data.RequiredAmount or 1
		local item = data.Item or data.Fish
		return {
			"ObtainItem",
			requiredAmount,
			arrayIfString(item),
			v,
			v2
		}
	end,
	HaveRod = function(p)
		local v = arrayIfString(p.Rod) -- equivalent call inferred; original call site unknown
		return { "HaveRod", #v, v }
	end,
	mutationDisplay = function(p: string)
		local module = require("../fishing/mutations")
		local mutation = module.Mutations[p]

		if typeof(mutation.Color) == "ColorSequence" then
			return GradientRichText(mutation.Display or p, mutation.Color)
		end

		return (`<font color="#{mutation.Color:ToHex()}">{mutation.Display or p}</font>`)
	end
}
local v = nil

function Lib.AllHuntFish()
	if v ~= nil then
		return v
	end

	local module = require("../library/fish")
	local result = {}

	for k, v2 in module do
		if typeof(v2) == "table" and v2.IsHuntFish then
			table.insert(result, k)
		end
	end

	v = result
	return result
end

local v2 = {
	__tostring = function(p)
		return (`<${p.__var}$>`)
	end
}

function Lib.var(var: string)
	return (setmetatable({
		__var = var
	}, v2))
end

function Lib.playerReply(continueText: string, exitText: string?)
	return table.freeze({
		continueText = continueText,
		exitText = exitText
	})
end

return Lib