local DataStoreService = game:GetService("DataStoreService")
local packages = script.Parent.Parent.Packages
local EasyStore = require(packages.EasyStore)
local RunContext = require(packages.RunContext)
local parent = script.Parent
local Tags = require(parent.Tags)
require(parent.Marketplace)
local v = EasyStore.Create("RELICSxyz", {
	Auras = {
		Rolls = 0,
		LastRenew = 0,
		Unlocks = {},
		Aura = nil
	},
	UGCSkin = {
		Skin = nil
	},
	Favorites = {},
	Settings = {},
	Recents = {},
	EquipWheel = {},
	Receipts = {},
	Unlocks = {
		Emotes = {},
		Skins = {},
		Playlists = {}
	},
	Version = nil
})
local v2 = {
	"Auras",
	"UGCSkin",
	"Settings",
	"Favorites"
}

local function readLegacyStore(owner: number)
	local dataStore = DataStoreService:GetDataStore("RELICSxyz", (`{owner}`))
	local result = {}

	for _, v3 in v2 do
		local v4 = v3
		local success, result2 = pcall(function()
			return dataStore:GetAsync(v4)
		end)

		if success then
			if type(result2) == "table" then
				result[v3] = result2
			end
		else
			warn((`[RelicsXYZ] Failed to read legacy '{v3}' for userId {owner}: {result2}`))
		end
	end

	return result
end

local function migrateV1(p, p2)
	for _, v3 in v2 do
		local v4 = p2[v3]

		if v4 ~= nil then
			p[v3] = v4
		end
	end
end

local function migrateV2(data, data2)
	local favorites = data2.Favorites

	if type(favorites) == "table" then
		local v3 = {}

		for _, favorite in data.Favorites do
			if type(favorite) == "string" then
				v3[favorite] = true
			end
		end

		for _, favorite in favorites do
			if type(favorite) ~= "string" or v3[favorite] then
				continue
			end

			table.insert(data.Favorites, favorite)
			v3[favorite] = true
		end
	end

	local settings = data2.Settings

	if type(settings) == "table" then
		for k, setting in settings do
			if not (type(k) == "string" and type(setting) == "boolean" and data.Settings[k] == nil) then
				continue
			end

			data.Settings[k] = setting
		end
	end

	local auras = data2.Auras

	if type(auras) == "table" then
		local unlocks = auras.Unlocks

		if type(unlocks) == "table" then
			for k, unlock in unlocks do
				if type(k) ~= "string" or not unlock or data.Auras.Unlocks[k] then
					continue
				end

				data.Auras.Unlocks[k] = true
			end
		end

		if data.Auras.Aura == nil and type(auras.Aura) == "string" then
			data.Auras.Aura = auras.Aura
		end

		if (data.Auras.Rolls or 0) == 0 and type(auras.Rolls) == "number" then
			data.Auras.Rolls = auras.Rolls
		end

		if (data.Auras.LastRenew or 0) == 0 and type(auras.LastRenew) == "number" then
			data.Auras.LastRenew = auras.LastRenew
		end
	end

	local uGCSkin = data2.UGCSkin

	if type(uGCSkin) == "table" and data.UGCSkin.Skin == nil and type(uGCSkin.Skin) == "string" then
		data.UGCSkin.Skin = uGCSkin.Skin
	end
end

local function migrateV5(p)
	local auras = p.Auras
	local unlocks = auras and auras.Unlocks

	if not unlocks then
		return
	end

	for k in unlocks do
		local v3 = k:gsub(" [Aa][Uu][Rr][Aa]", "")

		if v3 == k then
			continue
		end

		unlocks[v3] = true
		unlocks[k] = nil
	end
end

local function checkLegacyData(object)
	if not object.IsLoaded then
		return
	end

	local firstTagged = Tags.FindFirstTagged("RelicsDataConfig")
	local initialVersion = firstTagged and tonumber(firstTagged:GetAttribute("InitialVersion")) or 5
	local owner = object.Owner

	if (object.CurrentData.Version or initialVersion) >= 5 then
		return
	end

	object:Patch(function(p)
		local version = p.Version or 0

		if version < 2 then
			local v3 = readLegacyStore(owner)

			if version < 1 then
				for _, v4 in v2 do
					local v5 = v3[v4]

					if v5 ~= nil then
						p[v4] = v5
					end
				end
			end

			migrateV2(p, v3)
		end

		if version < 5 then
			migrateV5(p)
		end

		p.Version = 5
	end)
end

v:Start()

if RunContext.IsServer or RunContext.IsEdit then
	local Players = game:GetService("Players")

	local function onPlayerAdded(p)
		v:Load(p.UserId):andThen(checkLegacyData)
	end

	for _, v3 in Players:GetPlayers() do
		task.spawn(onPlayerAdded, v3)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
end

return table.freeze({
	Get = function(self: number?)
		return v:Get(self)
	end,
	Read = function(self: number?)
		return v:Read(self)
	end,
	PromiseRead = function(self: number?)
		return v:PromiseRead(self)
	end,
	Load = function(self: number?)
		return v:Load(self)
	end,
	Patch = function(self: number?, callback)
		return v:Get(self):Patch(callback)
	end
})