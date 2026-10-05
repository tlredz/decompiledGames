local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local parent = script.Parent.Parent
local React = require(shared.React)
require(shared.MusicData)
local Ownership = require(shared.Ownership)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent2 = script.Parent
local useOwnership = require(parent2.useOwnership)
local usePlayerData = require(parent2.usePlayerData)
local useMutexOwnership = require(parent2.useMutexOwnership)
local Enums = require(parent.Enums)
local State = require(parent.State)

local function usePlaylistLockState(data)
	local v = React.useContext(State.Context).Status == Enums.UserStatus.BoomboxPurchased

	if not data then
		return false, nil, Enum.InfoType.Asset
	end

	local v2 = v and true or data.IsFree
	local productType = data.ProductType
	local legacyIds = data.LegacyIds
	local productId = data.ProductId
	local v3 = React.useMemo(function()
		return Ownership.Get(data)
	end, { productId, legacyIds })
	local v4 = useOwnership(v3)
	local v5 = #v3 > 0
	local v6, v7 = useMutexOwnership(data, localPlayer.UserId)
	local v8 = usePlayerData("Unlocks/Playlists")
	local v9 = v8.Unlocks and v8.Unlocks.Playlists and v8.Unlocks.Playlists[data.Name]
	local v10 = false

	if v2 then
		local v11

		if v5 and data.IsFree == false then
			v11 = v4 ~= true
		else
			v11 = not v5 and data.RequiresPurchase == true and data.IsFree == false or false
		end

		v10 = v6 and not v7 and true or v11
	end

	if v10 and v9 then
		v10 = false
	end

	if data.IsIncluded then
		v10 = false
	end

	return v10, productId, productType
end

return usePlaylistLockState