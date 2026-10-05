local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local v = {
	Variant = {
		check = t.string,
		blank = function()
			return ""
		end
	},
	StartedAt = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	SetIndex = {
		check = t.number,
		blank = function()
			return 1
		end
	},
	Progress = {
		check = t.map(t.string, t.number),
		blank = function()
			return {}
		end
	},
	Claimed = {
		check = t.map(t.string, t.boolean),
		blank = function()
			return {}
		end
	},
	UnlockedPadlocks = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	PadlocksAcknowledged = {
		check = t.number,
		blank = function()
			return 0
		end
	},
	RewardGranted = {
		check = t.boolean,
		blank = function()
			return false
		end
	},
	RewardAcknowledged = {
		check = t.boolean,
		blank = function()
			return false
		end
	}
}
local checks = {}

for k, v2 in v do
	checks[k] = v2.check
end

local OnboardingQuestline = {
	State = t.interface(checks),
	Blank = function()
		local result = {}

		for k, v2 in v do
			result[k] = v2.blank()
		end

		return result
	end
}

function OnboardingQuestline.Reconcile(p)
	if type(p) ~= "table" then
		return OnboardingQuestline.Blank()
	end

	local clone = table.clone(p)

	for k, v2 in v do
		if not v2.check(clone[k]) then
			clone[k] = v2.blank()
		end
	end

	return clone
end

return OnboardingQuestline