local PrivateServerPropLimits = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local GroupUtil = require(ReplicatedStorage.Modules.Shared.Utils.GroupUtil)
local v = false
PrivateServerPropLimits.BASE_LIMIT = 500
PrivateServerPropLimits.INCREMENT = 100
PrivateServerPropLimits.MAX_LIMIT = 2000
PrivateServerPropLimits.WORKSPACE_ATTR = "PrivateServerPropLimit"
PrivateServerPropLimits.UNLOCK_ICON = "rbxassetid://98281797512672"

function PrivateServerPropLimits.ComputeLimit(p: number)
	return (math.min(
		PrivateServerPropLimits.BASE_LIMIT + PrivateServerPropLimits.INCREMENT * p,
		PrivateServerPropLimits.MAX_LIMIT
	))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOverrideLimit()
	if RunService:IsStudio() and not GameUtil.DEBUG_FORCE_PRIVATE_SERVER then
		return PrivateServerPropLimits.MAX_LIMIT
	end

	if v or GroupUtil.isIdContentCreator(GameUtil.GetPrivateServerOwner()) then
		v = true
		return PrivateServerPropLimits.MAX_LIMIT
	else
		return nil
	end
end

function PrivateServerPropLimits.ResolveLimit(p: number)
	local overrideLimit = getOverrideLimit() -- equivalent call inferred; original call site unknown

	if overrideLimit == nil then
		return PrivateServerPropLimits.ComputeLimit(p)
	end

	return overrideLimit
end

function PrivateServerPropLimits.GetLimits()
	local overrideLimit = getOverrideLimit() -- equivalent call inferred; original call site unknown

	if overrideLimit ~= nil then
		return overrideLimit
	end

	local attribute = workspace:GetAttribute(PrivateServerPropLimits.WORKSPACE_ATTR)

	if typeof(attribute) == "number" then
		return attribute
	end

	return PrivateServerPropLimits.BASE_LIMIT
end

return PrivateServerPropLimits