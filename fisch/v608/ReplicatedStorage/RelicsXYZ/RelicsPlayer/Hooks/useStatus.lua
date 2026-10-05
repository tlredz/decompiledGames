local parent = script.Parent
local Players = game:GetService("Players")
local parent2 = parent.Parent
local shared = parent2.Parent.Shared
require(shared.RunContext)
local useMutex = require(parent.useMutex)
local useAttribute = require(parent.useAttribute)
local usePlaylists = require(parent.usePlaylists)
local Enums = require(parent2.Enums)
local userStatus = Enums.UserStatus

local function useStatus()
	local localPlayer = Players.LocalPlayer
	local v = usePlaylists()
	local v2 = useAttribute(localPlayer, "RELICSxyz_Trial", function(p)
		return p and true or false
	end)
	local v3 = useAttribute(localPlayer, "RELICSxyz_MockFreemium", function(p)
		return p and true or false
	end)
	local v4 = useAttribute(localPlayer, "RELICSxyz_OwnsBoombox", function(p)
		return p and true or false
	end)
	local v5 = useMutex(localPlayer, "RELICSxyz_TemporaryBoombox")
	local flag = false

	for _, v7 in v do
		if not (v7.IsActive and v7.IsFree) then
			continue
		end

		flag = true
		break
	end

	if v3 then
		return userStatus.Freemium
	end

	if v4 or v5 then
		return userStatus.BoomboxPurchased
	end

	if v2 then
		return userStatus.TrialMode
	end

	if flag then
		return userStatus.Freemium
	end

	return userStatus.None
end

return useStatus