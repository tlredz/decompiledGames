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
	local unlocks = usePlayerData("Auras/Unlocks").Auras.Unlocks
	local v2 = useGamePasses({
		AssetType = "AURA",
		IncludeExpired = true,
		IncludeInactive = true
	})
	local v3 = React.useMemo(function()
		local bulkGet = Ownership.BulkGet(v2, function(p2)
			return p2.Name:gsub(" [Aa][Uu][Rr][Aa]", "")
		end)
		local result = {}

		for _, v4 in bulkGet do
			result[Ownership.KeyOf(v4.Id, v4.InfoType)] = v4.Key
		end

		return result
	end, { v2 })
	local v4 = React.useMemo(function()
		local result = {}

		for _, v5 in ipairs(v) do
			if typeof(v5) ~= "table" then
				continue
			end

			local id = v5.Id
			local infoType = v5.InfoType

			if type(id) ~= "number" or id <= 0 or infoType == nil then
				continue
			end

			table.insert(result, v5)
		end

		return result
	end, { v })
	local state, setState = React.useState({})
	React.useEffect(function()
		if #v4 == 0 then
			return
		end

		local v5 = true
		local v6 = Marketplace.BulkResolveOwnership(localPlayer, v4):andThen(function(p2)
			if not v5 then
				return
			end

			local v7 = {}

			for i, v8 in ipairs(v4) do
				local key = Ownership.KeyOf(v8.Id, v8.InfoType)
				local v9 = v3[key]

				if v9 and unlocks[v9] then
					v7[v8.Key or key] = true
				elseif not v7[v8.Key or key] then
					v7[v8.Key or key] = p2[i] or false
				end
			end

			setState(function(p3)
				local v8 = false

				for k, v10 in pairs(v7) do
					local v11 = p3[k] or v10 or false

					if p3[k] == v11 then
						continue
					end

					v8 = true
					break
				end

				if not v8 then
					return p3
				end

				local clone = table.clone(p3)

				for k, v10 in pairs(v7) do
					clone[k] = p3[k] or v10 or false
				end

				return clone
			end)
		end):catch(function(p2)
			warn("Bulk ownership resolve failed:", p2, v4)
		end)
		return function()
			v5 = false
			v6:cancel()
		end
	end, { v4, unlocks, v3 })
	React.useEffect(function()
		local v5 = Trove.new()

		for _, v6 in ipairs(v4) do
			local id = v6.Id
			local infoType = v6.InfoType
			local v7 = v6
			v5:Connect(Marketplace.GetOwnershipChangedSignal(localPlayer, id, infoType), function()
				local key = v7.Key or Ownership.KeyOf(id, infoType)
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
			v5:Clean()
		end
	end, { v4 })
	return (React.useMemo(function()
		local result = {}

		for _, v5 in ipairs(v4) do
			local key = v5.Key or Ownership.KeyOf(v5.Id, v5.InfoType)

			if not result[key] then
				result[key] = state[key]
			end
		end

		return result
	end, { v4, state }))
end

return useBulkOwnership