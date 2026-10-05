local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Defaults = require(script.Defaults)
local Schema = require(script.Types.Schema)

-- equivalent calls inferred from this helper; original call sites unknown
local function verifyAuthoredProfile(Defaults2)
	local v, v2 = Schema(Defaults2)

	if not v then
		error(`ProfileDefaults.Defaults violates the profile schema: {v2}`, 0)
	end
end

if Constants.IS_STUDIO then
	verifyAuthoredProfile(Defaults) -- equivalent call inferred; original call site unknown
end

return Defaults