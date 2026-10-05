local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Eggs = require(ReplicatedStorage.Shared.Types.Eggs)
local t = require(ReplicatedStorage.Packages.t)
local interface = t.interface({
	Uid = t.string,
	Egg = Eggs.SchemaValidation.SerializedSavedEgg
})
local mapped = t.map(t.string, t.number)
local v = {
	Requirements = {
		check = t.array(t.string),
		blank = function()
			return {}
		end
	},
	RequirementsBannerId = {
		check = t.string,
		blank = function()
			return ""
		end
	},
	Pity = {
		check = mapped,
		blank = function()
			return {}
		end
	},
	FreeRefreshDayKey = {
		check = t.string,
		blank = function()
			return ""
		end
	},
	FreeRefreshesUsed = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	TradeInsByBanner = {
		check = mapped,
		blank = function()
			return {}
		end
	},
	PendingReward = {
		check = t.union(t.literal(false), interface),
		blank = function()
			return false
		end
	},
	PaidRefreshDayKey = {
		check = t.optional(t.string),
		blank = function()
			return ""
		end
	},
	PaidRefreshesUsed = {
		check = t.optional(t.number),
		blank = function()
			return 0
		end
	}
}
local checks = {}

for k, v2 in v do
	checks[k] = v2.check
end

return {
	PendingReward = interface,
	State = t.interface(checks),
	Blank = function()
		local result = {}

		for k, v2 in v do
			result[k] = v2.blank()
		end

		return result
	end
}