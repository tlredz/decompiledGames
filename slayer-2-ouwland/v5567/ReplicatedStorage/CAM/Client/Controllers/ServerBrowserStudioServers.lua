local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Types = require(ReplicatedStorage.Communication.ServerAndClient.ServerBrowser.Types)

if RunService:IsStudio() then
	workspace:SetAttribute("ServerName", "Home-Server#0001")
end

local v = {
	"Otter",
	"Wolf",
	"Raven",
	"Fox",
	"Tiger",
	"Dragon",
	"Hawk",
	"Serpent",
	"Crane",
	"Shadow",
	"Leopard",
	"Mist",
	"Tempest",
	"Heron",
	"Lynx",
	"Ember"
}
local v2 = {
	{
		Region = 5,
		Players = 9,
		MaxPlayers = 20,
		Uptime = 10800,
		Current = true
	},
	{
		Region = 1,
		Players = 12,
		MaxPlayers = 20,
		Uptime = 7200,
		Friends = { "Kaito" }
	},
	{
		Region = 1,
		Players = 20,
		MaxPlayers = 20,
		Uptime = 18000
	},
	{
		Region = 2,
		Players = 3,
		MaxPlayers = 20,
		Uptime = 600
	},
	{
		Region = 3,
		Players = 17,
		MaxPlayers = 20,
		Uptime = 28800
	},
	{
		Region = 3,
		Players = 1,
		MaxPlayers = 20,
		Uptime = 90
	},
	{
		Region = 4,
		Players = 8,
		MaxPlayers = 20,
		Uptime = 3600
	},
	{
		Region = 5,
		Players = 19,
		MaxPlayers = 20,
		Uptime = 10800,
		Friends = {
			"Yumi",
			"Ren",
			"Sora",
			"Aoi"
		}
	},
	{
		Region = 5,
		Players = 6,
		MaxPlayers = 20,
		Uptime = 1200
	},
	{
		Region = 5,
		Players = 14,
		MaxPlayers = 20,
		Uptime = 43200
	},
	{
		Region = 6,
		Players = 2,
		MaxPlayers = 20,
		Uptime = 300
	},
	{
		Region = 7,
		Players = 11,
		MaxPlayers = 20,
		Uptime = 14400
	},
	{
		Region = 8,
		Players = 5,
		MaxPlayers = 20,
		Uptime = 2400
	},
	{
		Region = 5,
		Players = 9,
		MaxPlayers = 20,
		Uptime = 21600
	},
	{
		Region = 1,
		Players = 16,
		MaxPlayers = 20,
		Uptime = 5400
	},
	{
		Region = 7,
		Players = 20,
		MaxPlayers = 20,
		Uptime = 32400
	},
	{
		Region = 3,
		Players = 7,
		MaxPlayers = 20,
		Uptime = 1800
	}
}
local v3 = {}

local function records(placeId: number)
	if v3[placeId] ~= nil then
		return v3[placeId]
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local random = Random.new(placeId)
	local result = {}

	for k, v4 in v2 do
		local region = Types.Regions[v4.Region] or Types.Regions[1]
		table.insert(result, {
			Name = v4.Current and "Home-Server#0001" or string.format(
				"%s-%s#%04d",
				v[random:NextInteger(1, #v)],
				v[random:NextInteger(1, #v)],
				random:NextInteger(0, 9999)
			),
			JobId = string.format("studio-%d-%02d", placeId, k),
			PlaceId = placeId,
			Region = region,
			Players = v4.Players,
			MaxPlayers = v4.MaxPlayers,
			Version = "v.studio",
			StartTime = serverTimeNow - v4.Uptime,
			Friends = v4.Friends
		})
	end

	for i = #v2 + 1, #v2 + 0 do
		table.insert(result, {
			Name = string.format(
				"%s-%s#%04d",
				v[random:NextInteger(1, #v)],
				v[random:NextInteger(1, #v)],
				random:NextInteger(0, 9999)
			),
			JobId = string.format("studio-%d-%02d", placeId, i),
			PlaceId = placeId,
			Region = Types.Regions[random:NextInteger(1, #Types.Regions)],
			Players = random:NextInteger(0, 20),
			MaxPlayers = 20,
			Version = "v.studio",
			StartTime = serverTimeNow - random:NextInteger(60, 50400)
		})
	end

	v3[placeId] = result
	return result
end

local ServerBrowserStudioServers = {}

function ServerBrowserStudioServers.Browse(placeId: number, value: string?)
	local v4

	if typeof(value) == "string" then
		v4 = string.lower(value)
	end

	local v5 = v4 == nil or v4 == string.lower(Types.All) or v4 == string.lower(Types.Unknown)
	local clones = {}

	for _, v6 in records(placeId) do
		if v5 or string.lower(v6.Region) == v4 then
			table.insert(clones, table.clone(v6))
		end
	end

	return clones
end

function ServerBrowserStudioServers.Search(placeId: number, value: string)
	local v4 = string.lower(string.gsub(value, "[^%a%d#%-]", ""))
	local clones = {}

	if #v4 < Types.MinQuery then
		return clones
	end

	for _, v5 in records(placeId) do
		if string.sub(string.lower(v5.Name), 1, #v4) ~= v4 then
			continue
		end

		table.insert(clones, table.clone(v5))
	end

	return clones
end

return ServerBrowserStudioServers