require("./Types")
local module = require("@self/constants")
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function _sett(p)
	return function(p2)
		count += 1
		p2.Order = count
		p2.Type = p
		return p2
	end
end

local v2 = _sett("toggle") -- equivalent call inferred; original call site unknown
local TesterSettings = {
	disableZoneCutscenes = v2({
		Name = "Disable Zone Discovery Cutscenes",
		Description = "hey have u seen this new zone its called: Living Garden"
	}),
	autoGiveUtility = v2({
		Name = "Auto-Give Utility Items",
		Description = [[
Automatically gives the following items after a resync or hardwipe (if they are not already owned):
]] .. table.concat(module.UTILITY_ITEMS, ", ")
	}),
	skipTutorial = v2({
		Name = "Auto-Skip Tutorial",
		Description = "Automatically skips the tutorial after hardwiping."
	}),
	persistQuickAccess = v2({
		Name = "Persistent Quick Access",
		Description = "Keeps your Quick Access settings after a hardwipe or resync."
	}),
	transferCaughtBy = v2({
		Name = "Transfer \"Caught By\"",
		Description = "When syncing data with another player, transfers the \"Caught By\" data on their fish to your own user ID, so quests reading this value will work as if you caught them"
	}),
	teleportBack = v2({
		Name = "Auto-Teleport Back",
		Description = "After hardwiping or resyncing, teleports you back to where you were when running the command"
	})
}

for k, v3 in TesterSettings do
	v3.Id = k
end

return TesterSettings