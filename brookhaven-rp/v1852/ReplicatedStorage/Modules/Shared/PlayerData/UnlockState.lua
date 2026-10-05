local UnlockState = {}
UnlockState.__index = UnlockState
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
UnlockState.stateInterface = t.strictInterface({
	isPermanent = t.optional(t.boolean),
	expirationUnix = t.optional(t.number)
})

function UnlockState.new(data)
	local object = setmetatable({}, UnlockState)
	object.isPermanent = data.isPermanent
	object.expirationUnix = data.expirationUnix
	object.isGamepassUnlocked = data.isGamepassUnlocked
	return object
end

function UnlockState.IsPermanent(p)
	return p.isPermanent
end

function UnlockState.IsGamepassUnlocked(p)
	return p.isGamepassUnlocked
end

function UnlockState.GetExpirationUnix(p)
	return p.expirationUnix
end

function UnlockState.HasAccess(data)
	if data.isPermanent or data.isGamepassUnlocked or data.expirationUnix and workspace:GetServerTimeNow() < data.expirationUnix then
		return true
	end

	return false
end

return UnlockState