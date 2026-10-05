local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.MoveReplication.Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function _isCmvfxActive()
	local customMoveVFX = ReplicatedStorage:FindFirstChild("CustomMoveVFX")
	local cast = customMoveVFX and customMoveVFX:FindFirstChild("Cast")
	return cast and cast:FindFirstChild("LivePlayCastEvent") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bus()
	return ReplicatedStorage:FindFirstChild("Replication")
end

local function effectName(p)
	return (tostring(type(p) == "table" and p.Effect or "?"))
end

local function describe(p)
	if type(p) ~= "table" then
		return ""
	end

	local event = p.Event

	if type(event) ~= "table" then
		return "uid=? (no Event)"
	end

	local v = type(event.Properties) ~= "table" and {} or event.Properties or {}
	return string.format(
		"uid=%s t=%s type=%s branch=%s",
		tostring(event.uid or v.__EditorUid),
		tostring(event.Time),
		tostring(event.EventType),
		(tostring(event.Branch or v._branch))
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dispatchLocal(p)
	local repfire = shared and shared.repfire

	if type(repfire) == "function" then
		local success, result = pcall(repfire, p)

		if not success then
			warn("[MoveRelay][client] shared.repfire err: " .. tostring(result))
		end
	end
end

local MoveEffectRelay = {}

function MoveEffectRelay.fireAll(_, p)
	if RunService:IsClient() then
		dispatchLocal(p) -- equivalent call inferred; original call site unknown
	else
		local v = bus() -- equivalent call inferred; original call site unknown

		if not v then
			return
		end

		v:FireAllClients(p)
	end
end

function MoveEffectRelay.fireClient(_, player, p)
	if RunService:IsClient() then
		if player ~= nil then
			local Players = game:GetService("Players")

			if player ~= Players.LocalPlayer then
				return
			end
		end

		dispatchLocal(p) -- equivalent call inferred; original call site unknown
	else
		if _isCmvfxActive() then
			return
		end

		local v = bus() -- equivalent call inferred; original call site unknown

		if not v then
			return
		end

		v:FireClient(player, p)
	end
end

return MoveEffectRelay