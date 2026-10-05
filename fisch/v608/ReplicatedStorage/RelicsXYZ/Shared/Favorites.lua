local v = {}
local parent = script.Parent
local Network = require(parent.Network)
require(parent.Promise)
local PlayerData = require(parent.PlayerData)
local RunContext = require(parent.RunContext)

-- equivalent calls inferred from this helper; original call sites unknown
local function validateSongId(value)
	assert(type(value) == "string", "Expected songId to be a string")
	assert(value:match("rbxassetid://%d+"), "Expected songId to be a valid asset ID in the format rbxassetid://<id>")
	return value
end

local function validateOrder(list)
	assert(type(list) == "table", "Expected new order to be an array of song ids")
	local v2 = {}
	local result = {}

	for _, v3 in ipairs(list) do
		if v2[validateSongId(v3)] then
			continue
		end

		table.insert(result, v3)
		v2[v3] = true
	end

	return result
end

local event = Network.Event("RELICSxyz_AddFavorite", validateSongId)
local event2 = Network.Event("RELICSxyz_RemoveFavorite", validateSongId)
local event3 = Network.Event("RELICSxyz_ReorderFavorites", validateOrder)

function v.Add(p: string, p2: number?)
	if RunContext.IsServer or RunContext.IsEdit then
		PlayerData.Get(p2):Patch(function(p3)
			local favorites = p3.Favorites

			if not table.find(favorites, p) then
				table.insert(favorites, 1, p)
			end
		end)
	else
		event:Client():Fire(p)
	end
end

function v.Remove(p: string, userId: number?)
	if not (RunContext.IsServer or RunContext.IsEdit) then
		event2:Client():Fire(p)
		return
	end

	if RunContext.IsEdit then
		local StudioService = game:GetService("StudioService")
		userId = StudioService:GetUserId()
	end

	assert(userId, "Expected userId to be provided on the server")
	PlayerData.Get(userId):Patch(function(p2)
		local favorites = p2.Favorites
		local index = table.find(favorites, p)

		if index then
			table.remove(favorites, index)
		end
	end)
end

function v.Reorder(p, p2: number?)
	local v2 = validateOrder(p)

	if not (RunContext.IsServer or RunContext.IsEdit) then
		event3:Client():Fire(v2)
		return
	end

	if RunContext.IsEdit then
		local StudioService = game:GetService("StudioService")
		p2 = p2 or StudioService:GetUserId()
	end

	assert(p2, "Expected userId to be provided on the server")
	PlayerData.Get(p2):Patch(function(p3)
		local favorites = p3.Favorites
		local v3 = {}

		for _, favorite in ipairs(favorites) do
			v3[favorite] = true
		end

		local favorites2 = {}

		for _, v5 in ipairs(v2) do
			if v3[v5] then
				table.insert(favorites2, v5)
			end
		end

		for _, favorite in ipairs(favorites) do
			if not table.find(favorites2, favorite) then
				table.insert(favorites2, favorite)
			end
		end

		p3.Favorites = favorites2
	end)
end

function v.TryGet(p: number?)
	local v2 = PlayerData.Read(p)
	return v2 and v2.Favorites or nil
end

function v.Promise(p: number?)
	return PlayerData.Load(p):andThen(function(p2)
		return p2.Favorites
	end):catch(function(p2)
		warn("Failed to get favorites for userId", p, ":", p2)
		return {}
	end)
end

if not RunContext.IsServer then
	return table.freeze(v)
end

local server = event:Server()
local server2 = event2:Server()
local server3 = event3:Server()
server:On(function(p, p2)
	local userId = p.UserId
	v.Add(p2, userId)
end)
server2:On(function(p, p2)
	local userId = p.UserId
	v.Remove(p2, userId)
end)
server3:On(function(p, p2)
	v.Reorder(p2, p.UserId)
end)
return table.freeze(v)