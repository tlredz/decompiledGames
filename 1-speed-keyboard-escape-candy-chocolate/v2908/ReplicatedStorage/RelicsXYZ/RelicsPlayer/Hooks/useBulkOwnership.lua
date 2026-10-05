local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local parent = script.Parent
local useGamePasses = require(parent.useGamePasses)
local usePlayerData = require(parent.usePlayerData)
local React = require(shared.React)
local Trove = require(shared.Trove)
local Ownership = require(shared.Ownership)
require(shared.GamePasses)
local Marketplace = require(shared.Marketplace)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function useBulkOwnership(callback, p)
	local v = React.useMemo(function()
		if type(callback) == "function" then
			return callback()
		end

		return callback
	end, p)
	local v2 = usePlayerData()
	local unlocks = v2.Auras.Unlocks
	local receipts = v2.Receipts
	local v3 = useGamePasses({
		AssetType = "AURA",
		IncludeExpired = true,
		IncludeInactive = true
	})
	local v4 = React.useMemo(function()
		local bulkGet = Ownership.BulkGet(v3, function(p2)
			return p2.Name:gsub(" [Aa][Uu][Rr][Aa]", "")
		end)
		local result = {}

		for _, v5 in bulkGet do
			result[Ownership.KeyOf(v5.Id, v5.InfoType)] = v5.Key
		end

		return result
	end, { v3 })
	local v5 = React.useMemo(function()
		local result = {}

		for _, v6 in ipairs(v) do
			if typeof(v6) ~= "table" then
				continue
			end

			local id = v6.Id
			local infoType = v6.InfoType

			if type(id) ~= "number" or id <= 0 or infoType == nil then
				continue
			end

			table.insert(result, v6)
		end

		return result
	end, { v })
	local state, setState = React.useState({})
	React.useEffect(function()
		if #v5 == 0 then
			return
		end

		local v6 = true
		local v7 = Marketplace.BulkResolveOwnership(localPlayer, v5):andThen(function(p2)
			if not v6 then
				return
			end

			local v8 = {}

			for i, v9 in ipairs(v5) do
				local key = Ownership.KeyOf(v9.Id, v9.InfoType)
				local v10 = v4[key]

				if v10 and unlocks[v10] then
					v8[v9.Key or key] = true
				else
					local key2 = v9.Key or key

					if not v8[key2] then
						v8[key2] = p2[i] or false
					end
				end
			end

			setState(function(p3)
				local v9 = false

				for k, v11 in pairs(v8) do
					local v12 = p3[k] or v11 or false

					if p3[k] == v12 then
						continue
					end

					v9 = true
					break
				end

				if not v9 then
					return p3
				end

				local clone = table.clone(p3)

				for k, v11 in pairs(v8) do
					clone[k] = p3[k] or v11 or false
				end

				return clone
			end)
		end):catch(function(p2)
			warn("Bulk ownership resolve failed:", p2, v5)
		end)
		return function()
			v6 = false
			v7:cancel()
		end
	end, {
		v5,
		receipts,
		unlocks,
		v4
	})
	React.useEffect(function()
		local v6 = Trove.new()

		for _, v7 in ipairs(v5) do
			local id = v7.Id
			local infoType = v7.InfoType
			local v8 = v7
			v6:Connect(Marketplace.GetOwnershipChangedSignal(localPlayer, id, infoType), function()
				local key = v8.Key or Ownership.KeyOf(id, infoType)
				setState(function(p2)
					if p2[key] == true then
						return p2
					end

					local clone = table.clone(p2)
					clone[key] = true
					return clone
				end)
			end)
		end

		return function()
			v6:Clean()
		end
	end, { v5 })
	return (React.useMemo(function()
		local result = {}

		for _, v6 in ipairs(v5) do
			local key = v6.Key or Ownership.KeyOf(v6.Id, v6.InfoType)

			if not result[key] then
				result[key] = state[key]
			end
		end

		return result
	end, { v5, state }))
end

return useBulkOwnership