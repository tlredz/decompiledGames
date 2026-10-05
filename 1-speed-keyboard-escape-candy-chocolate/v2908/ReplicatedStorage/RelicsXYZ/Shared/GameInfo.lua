local parent = script.Parent
local Signal = require(parent.Signal)
local Backend = require(parent.Backend)
local RunContext = require(parent.RunContext)
local v = nil
local gameInfoUpdated = Signal.new()

if RunContext.IsServer or RunContext.IsEdit then
	local function fetchGameInfo()
		Backend.GET("roblox/games"):andThen(function(data)
			if data then
				script:SetAttribute("Id", data.id)
				script:SetAttribute("Name", data.name)
				script:SetAttribute("FeaturedImageId", data.featuredImageId)
			end
		end):catch(function(p)
			warn("[GameInfo] Failed to fetch game info:", p)
		end)
	end

	fetchGameInfo()
end

local function updateGameInfo()
	local featuredImageId = script:GetAttribute("FeaturedImageId")
	local name = script:GetAttribute("Name")
	local id = script:GetAttribute("Id")
	v = {
		Id = type(id) == "string" and id or nil,
		Name = type(name) == "string" and name or nil,
		FeaturedImageId = type(featuredImageId) == "string" and featuredImageId or nil
	}
	return v
end

local function getGameInfo()
	if v == nil then
		updateGameInfo()
	end

	return assert(v)
end

local function getFeaturedImageId()
	if v == nil then
		updateGameInfo()
	end

	return assert(v).FeaturedImageId
end

script.AttributeChanged:Connect(function()
	gameInfoUpdated:Fire((updateGameInfo()))
end)
return table.freeze({
	GetGameInfo = getGameInfo,
	GameInfoUpdated = gameInfoUpdated,
	GetFeaturedImageId = getFeaturedImageId
})