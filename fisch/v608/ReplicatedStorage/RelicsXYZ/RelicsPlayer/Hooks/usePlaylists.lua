local relicsXYZ = script:FindFirstAncestor("RelicsXYZ")
local Players = game:GetService("Players")
local shared = relicsXYZ.Shared
local MusicData = require(shared.MusicData)
local Ownership = require(shared.Ownership)
local React = require(shared.React)
local parent = script.Parent
local useSignal = require(parent.useSignal)
local useBulkOwnership = require(parent.useBulkOwnership)
local localPlayer = Players.LocalPlayer

local function usePlaylists(p)
	local includeInactiveUnowned = p and p.IncludeInactiveUnowned
	local state, setState = React.useState(function()
		return MusicData.GetPlaylists(p and p.PublicPlaylists)
	end)
	local state2, setState2 = React.useState({})
	useSignal(MusicData.PlaylistAdded, function(_)
		setState((MusicData.GetPlaylists(p and p.PublicPlaylists)))
	end, {})
	useSignal(MusicData.PlaylistRemoved, function(_)
		setState((MusicData.GetPlaylists(p and p.PublicPlaylists)))
	end, {})
	local ref = React.useRef({})
	React.useEffect(function()
		return function()
			for _, connection in pairs(ref.current) do
				connection:Disconnect()
			end

			table.clear(ref.current)
		end
	end, {})
	React.useEffect(function()
		local v = {}

		for _, v2 in ipairs(state) do
			v[v2.Id] = true
		end

		local v2 = {}

		for _, v3 in ipairs(state) do
			if ref.current[v3.Id] then
				continue
			end

			local ownershipChangedSignal = MusicData.GetOwnershipChangedSignal(v3, localPlayer.UserId)
			v2[v3.Id] = MusicData.UserHasUnlocked(v3, localPlayer.UserId)
			local v4 = v3
			ref.current[v3.Id] = ownershipChangedSignal:Connect(function(p2)
				setState2(function(p3)
					local clone = table.clone(p3)
					clone[v4.Id] = p2
					return clone
				end)
			end)
		end

		for k, connection in pairs(ref.current) do
			if v[k] then
				continue
			end

			connection:Disconnect()
			ref.current[k] = nil
		end

		setState2(function(items)
			local v3 = false

			for k, v5 in pairs(v2) do
				if items[k] == v5 then
					continue
				end

				v3 = true
				break
			end

			if not v3 then
				for k in pairs(items) do
					if v[k] then
						continue
					end

					v3 = true
					break
				end
			end

			if not v3 then
				return items
			end

			local clone = table.clone(items)

			for k, v5 in pairs(v2) do
				clone[k] = v5
			end

			for k in pairs(clone) do
				if not v[k] then
					clone[k] = nil
				end
			end

			return clone
		end)
	end, { state })
	local v = useBulkOwnership(function()
		return Ownership.BulkGet(state, function(p2)
			return (`PLAYLIST:{p2.Id}`)
		end)
	end, { state })
	return (React.useMemo(function()
		if includeInactiveUnowned then
			return state
		end

		local result = {}

		for _, v2 in ipairs(state) do
			local v3 = v[`PLAYLIST:{v2.Id}`]
			local v4 = state2[v2.Id]

			if v2.IsActive or v3 or v4 then
				table.insert(result, v2)
			end
		end

		return result
	end, {
		state,
		v,
		state2,
		includeInactiveUnowned
	}))
end

return usePlaylists