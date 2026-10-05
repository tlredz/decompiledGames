local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {
		Lock = function(_, value: string?)
			return value or ""
		end,
		Unlock = function(_, _: string) end,
		ForceUnlockAll = function(_) end,
		IsLocked = function(_)
			return false
		end,
		GetActiveLocks = function(_)
			return {}
		end
	}
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = false
local v3 = nil
local count = 0

local function getControls()
	if v3 then
		return v3
	end

	local playerScripts = localPlayer:FindFirstChild("PlayerScripts")

	if not playerScripts then
		return nil
	end

	local playerModule = playerScripts:FindFirstChild("PlayerModule")

	if not playerModule then
		return nil
	end

	local success, result = pcall(function()
		local module = require(playerModule)
		return module:GetControls()
	end)

	if success and result then
		v3 = result
		return v3
	end

	local controlModule = playerModule:FindFirstChild("ControlModule")

	if controlModule then
		local success2, result2 = pcall(require, controlModule)

		if success2 and result2 then
			v3 = result2
		end
	end

	return v3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function syncControls()
	local v4 = next(v) ~= nil

	if v4 == v2 then
		return
	end

	local controls = getControls()

	if not controls then
		return
	end

	if v4 then
		controls:Disable()
	else
		controls:Enable()
	end

	v2 = v4
end

local PlayerMovementController = {}

function PlayerMovementController.Lock(_, p: string?)
	if p == nil then
		count += 1
		p = "AutoLock_" .. count
	end

	v[p] = true
	syncControls() -- equivalent call inferred; original call site unknown
	return p
end

function PlayerMovementController.Unlock(_, p: string)
	if p == nil then
		warn("[PlayerMovementController] Unlock called with no reason — ignoring. Pass the reason returned by :Lock, or use :ForceUnlockAll to clear everything.")
		return
	end

	if not v[p] then
		return
	end

	v[p] = nil
	syncControls() -- equivalent call inferred; original call site unknown
end

function PlayerMovementController.ForceUnlockAll(_)
	table.clear(v)
	syncControls() -- equivalent call inferred; original call site unknown
end

function PlayerMovementController.IsLocked(_)
	return next(v) ~= nil
end

function PlayerMovementController.GetActiveLocks(_)
	local result = {}

	for k in v do
		table.insert(result, k)
	end

	return result
end

return PlayerMovementController