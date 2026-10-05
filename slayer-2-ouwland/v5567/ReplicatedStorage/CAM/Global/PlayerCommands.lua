local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- equivalent calls inferred from this helper; original call sites unknown
local function service()
	local PrivateServerService = require(ServerStorage.SAM.Services.PrivateServerService)
	return PrivateServerService
end

local function playersHere()
	local names = {}

	for _, v in Players:GetPlayers() do
		table.insert(names, v.Name)
	end

	return names
end

local function playersHereAndFriends()
	local names = {}

	for _, v in Players:GetPlayers() do
		table.insert(names, v.Name)
	end

	local v = {}

	for _, v2 in names do
		v[v2] = true
	end

	local friendsHandler = require(ReplicatedStorage.CAM.Global.friendsHandler)

	for _, v2 in friendsHandler.getAllFriends() do
		if v[v2.name] then
			continue
		end

		v[v2.name] = true
		table.insert(names, v2.name)
	end

	return names
end

local function targeted(p: string, flag: boolean)
	return function(p2, list)
		local PrivateServerService = service() -- equivalent call inferred; original call site unknown
		local userId, v2 = PrivateServerService.ResolveUserId(list[1], flag)

		if userId == nil then
			return false, v2
		end

		return PrivateServerService[p](p2, userId)
	end
end

local function switch(value: string)
	return function(p, list)
		local lower = (list[1] or ""):lower()

		if lower ~= "on" and lower ~= "off" then
			return false, (`Usage: /{value:lower()} on | off`)
		end

		return (service()).SetSetting(p, value, lower == "on")
	end
end

local function player(required: boolean, flag2: boolean?)
	local suggester

	if flag2 then
		suggester = playersHereAndFriends
	else
		suggester = playersHere
	end

	return {
		Name = "player",
		Required = required,
		Suggester = suggester
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function words(name: string, p2)
	return {
		Name = name,
		Required = true,
		Suggester = function()
			return p2
		end
	}
end

local function spawnAllowed()
	local SpawnAnywhere = require(ServerStorage.SAM.Utility.SpawnAnywhere)
	return SpawnAnywhere.Allowed()
end

local v = {
	Name = "kick",
	Set = "PrivateServer",
	Need = "Moderator",
	Usage = "/kick <player>",
	Help = "Remove someone from this server now.",
	Args = {
		{
			Name = "player",
			Required = true,
			Suggester = playersHere
		}
	},
	Run = 0
}
local v2 = false
local v3 = "Kick"

function v.Run(p, list)
	local PrivateServerService = service() -- equivalent call inferred; original call site unknown
	local userId, v5 = PrivateServerService.ResolveUserId(list[1], v2)

	if userId == nil then
		return false, v5
	end

	return PrivateServerService[v3](p, userId)
end

local v4 = {
	Name = "ban",
	Set = "PrivateServer",
	Need = "Moderator",
	Usage = "/ban <player>",
	Help = "Keep someone out for good. They need not be here.",
	Args = {
		{
			Name = "player",
			Required = true,
			Suggester = playersHereAndFriends
		}
	},
	Run = 0
}
local v5 = true
local v6 = "BanAdd"

function v4.Run(p, list)
	local PrivateServerService = service() -- equivalent call inferred; original call site unknown
	local userId, v8 = PrivateServerService.ResolveUserId(list[1], v5)

	if userId == nil then
		return false, v8
	end

	return PrivateServerService[v6](p, userId)
end

local v7 = {
	Name = "unban",
	Set = "PrivateServer",
	Need = "Moderator",
	Usage = "/unban <player>",
	Help = "Let a banned player back in.",
	Args = {
		{
			Name = "player",
			Required = true,
			Suggester = playersHereAndFriends
		}
	},
	Run = 0
}
local v8 = true
local v9 = "BanRemove"

function v7.Run(p, list)
	local PrivateServerService = service() -- equivalent call inferred; original call site unknown
	local userId, v11 = PrivateServerService.ResolveUserId(list[1], v8)

	if userId == nil then
		return false, v11
	end

	return PrivateServerService[v9](p, userId)
end

local v10 = {
	Name = "whitelist",
	Alias = "wl",
	Set = "PrivateServer",
	Need = "Moderator",
	Usage = "/whitelist <player>",
	Help = "Always let this player in, whatever the access mode is.",
	Args = {
		{
			Name = "player",
			Required = true,
			Suggester = playersHereAndFriends
		}
	},
	Run = 0
}
local v11 = true
local v12 = "WhitelistAdd"

function v10.Run(p, list)
	local PrivateServerService = service() -- equivalent call inferred; original call site unknown
	local userId, v14 = PrivateServerService.ResolveUserId(list[1], v11)

	if userId == nil then
		return false, v14
	end

	return PrivateServerService[v12](p, userId)
end

local v13 = {
	Name = "unwhitelist",
	Alias = "unwl",
	Set = "PrivateServer",
	Need = "Moderator",
	Usage = "/unwhitelist <player>",
	Help = "Take a player off the whitelist.",
	Args = {
		{
			Name = "player",
			Required = true,
			Suggester = playersHereAndFriends
		}
	},
	Run = 0
}
local v14 = true
local v15 = "WhitelistRemove"

function v13.Run(p, list)
	local PrivateServerService = service() -- equivalent call inferred; original call site unknown
	local userId, v17 = PrivateServerService.ResolveUserId(list[1], v14)

	if userId == nil then
		return false, v17
	end

	return PrivateServerService[v15](p, userId)
end

local v16 = {
	Name = "mod",
	Set = "PrivateServer",
	Need = "Owner",
	Usage = "/mod <player>",
	Help = "Make a player a moderator of your server.",
	Args = {
		{
			Name = "player",
			Required = true,
			Suggester = playersHereAndFriends
		}
	},
	Run = 0
}
local v17 = true
local v18 = "ModeratorAdd"

function v16.Run(p, list)
	local PrivateServerService = service() -- equivalent call inferred; original call site unknown
	local userId, v20 = PrivateServerService.ResolveUserId(list[1], v17)

	if userId == nil then
		return false, v20
	end

	return PrivateServerService[v18](p, userId)
end

local v19 = {
	Name = "unmod",
	Set = "PrivateServer",
	Need = "Owner",
	Usage = "/unmod <player>",
	Help = "Take a player's moderator role away.",
	Args = {
		{
			Name = "player",
			Required = true,
			Suggester = playersHereAndFriends
		}
	},
	Run = 0
}
local v20 = true
local v21 = "ModeratorRemove"

function v19.Run(p, list)
	local PrivateServerService = service() -- equivalent call inferred; original call site unknown
	local userId, v23 = PrivateServerService.ResolveUserId(list[1], v20)

	if userId == nil then
		return false, v23
	end

	return PrivateServerService[v21](p, userId)
end

local v22 = {
	Name = "access",
	Set = "PrivateServer",
	Need = "Moderator",
	Broadcasts = true,
	Usage = "/access closed | friends | everyone",
	Help = "Who may join. Nobody already inside is thrown out when it tightens.",
	Args = { words("mode", { "closed", "friends", "everyone" }) },
	Run = function(p, list)
		local v24 = list[1] or ""
		return (service()).SetAccess(p, v24:sub(1, 1):upper() .. v24:sub(2):lower())
	end
}
local v24 = {
	Name = "pvp",
	Set = "PrivateServer",
	Need = "Moderator",
	Anywhere = true,
	Broadcasts = true,
	Usage = "/pvp on | off",
	Help = "Whether players may damage each other.",
	Args = { words("state", { "on", "off" }) },
	Run = 0
}
local v26 = "PvP"

function v24.Run(p, list)
	local lower = (list[1] or ""):lower()

	if lower ~= "on" and lower ~= "off" then
		return false, (`Usage: /{v26:lower()} on | off`)
	end

	return (service()).SetSetting(p, v26, lower == "on")
end

local v27 = {
	Name = "pve",
	Set = "PrivateServer",
	Need = "Moderator",
	Anywhere = true,
	Broadcasts = true,
	Usage = "/pve on | off",
	Help = "Off means NO NPCs at all: none spawn and none pay out.",
	Args = { words("state", { "on", "off" }) },
	Run = 0
}
local v29 = "PvE"

function v27.Run(p, list)
	local lower = (list[1] or ""):lower()

	if lower ~= "on" and lower ~= "off" then
		return false, (`Usage: /{v29:lower()} on | off`)
	end

	return (service()).SetSetting(p, v29, lower == "on")
end

local list2 = {
	v,
	v4,
	v7,
	v10,
	v13,
	v16,
	v19,
	v22,
	v24,
	v27,
	{
		Name = "announce",
		Set = "PrivateServer",
		Need = "Moderator",
		Anywhere = true,
		Rest = true,
		Usage = "/announce <message>",
		Help = "Say something to everyone in this server.",
		Args = {
			{
				Name = "message",
				Required = true
			}
		},
		Run = function(p, list)
			local PrivateServerService = service() -- equivalent call inferred; original call site unknown
			return PrivateServerService.Announce(p, table.concat(list, " "))
		end
	},
	{
		Name = "shutdown",
		Set = "PrivateServer",
		Need = "Owner",
		Usage = "/shutdown",
		Help = "Everyone out. The server restarts clean on the next join.",
		Args = {},
		Run = function(p)
			local PrivateServerService = service() -- equivalent call inferred; original call site unknown
			return PrivateServerService.Shutdown(p)
		end
	},
	{
		Name = "set",
		Set = "SpawnAnywhere",
		Gamepass = "Spawn Anywhere",
		PlaceGate = spawnAllowed,
		Usage = "/set",
		Help = "The spot you are standing on becomes where you respawn in this world.",
		Args = {},
		Run = function(player2)
			local Checker = require(ReplicatedStorage.CAM.Global.Checker)
			local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
			local SpawnAnywhere = require(ServerStorage.SAM.Utility.SpawnAnywhere)
			local Utility = require(ReplicatedStorage.CAM.Global.Utility)
			local data = Utility.GetData(player2)

			if data == nil then
				return false, "Your data isn't loaded yet"
			end

			if not SpawnAnywhere.Allowed() then
				return false, "Spawn Anywhere is not available here"
			end

			local character = player2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart == nil then
				return false, "No character to set the spawn from"
			end

			if Checker.check(player2, nil, "Riding") and not InCombat.Regular(character) then
				SpawnAnywhere.Set(data, humanoidRootPart.Position)
				return true, "Spawn Set"
			else
				return false, "You can not set your spawn right now"
			end
		end
	},
	{
		Name = "unset",
		Set = "SpawnAnywhere",
		Gamepass = "Spawn Anywhere",
		PlaceGate = spawnAllowed,
		Usage = "/unset",
		Help = "Back to respawning at your equipped region spawn.",
		Args = {},
		Run = function(p)
			local SpawnAnywhere = require(ServerStorage.SAM.Utility.SpawnAnywhere)
			local Utility = require(ReplicatedStorage.CAM.Global.Utility)
			local data = Utility.GetData(p)

			if data == nil then
				return false, "Your data isn't loaded yet"
			end

			if not SpawnAnywhere.Allowed() then
				return false, "Spawn Anywhere is not available here"
			end

			SpawnAnywhere.Unset(data)
			return true, "Spawn Unset"
		end
	}
}
local PlayerCommands = {
	List = list2,
	Sets = {
		Private = "PrivateServer",
		Spawn = "SpawnAnywhere"
	},
	ByName = function(value: string?)
		if value == nil or value == "" then
			return nil
		end

		local lower = value:lower()

		if lower:sub(1, 1) == "/" then
			lower = lower:sub(2)
		end

		for _, v31 in list2 do
			if v31.Name == lower or v31.Alias == lower then
				return v31
			end
		end

		return nil
	end
}

function PlayerCommands.Parse(value: string)
	local result = {}

	for k in value:gmatch("%S+") do
		table.insert(result, k)
	end

	local v31 = table.remove(result, 1)
	return PlayerCommands.ByName(v31), result
end

function PlayerCommands.Available(p)
	local result = {}

	if p == nil then
		return result
	end

	local PrivateServerService = service() -- equivalent call inferred; original call site unknown
	local Config = require(ServerStorage.SAM.Services.PrivateServerService.Config)
	PrivateServerService.ResolveSession()
	local role = PrivateServerService.RoleOf(p)
	local v32 = Config.ROLE_RANK[role] or 0
	local v33 = PrivateServerService.GetState(p) ~= nil
	local Shop = require(ReplicatedStorage.CAM.Global.Shop)

	for _, v34 in list2 do
		if not ((v34.Set ~= "PrivateServer" or not (v32 < (Config.ROLE_RANK[v34.Need] or 1e999)) and (v34.Anywhere or v33)) and (v34.PlaceGate == nil or v34.PlaceGate())) then
			continue
		end

		if not (v34.Gamepass == nil or Shop.OwnsGamepassListing(p, v34.Gamepass)) then
			continue
		end

		result[v34.Name] = true
	end

	return result
end

function PlayerCommands.MissingPass(p, p2)
	if p2.Gamepass == nil or p2.PlaceGate ~= nil and not p2.PlaceGate() then
		return nil
	end

	local Shop = require(ReplicatedStorage.CAM.Global.Shop)

	if Shop.OwnsGamepassListing(p, p2.Gamepass) then
		return nil
	end

	local v31 = Shop.itemsforsale[p2.Gamepass]
	local v32

	if v31 ~= nil then
		return v31.Price ~= nil and v31.Price.Gamepass or nil
	end

	return v32
end

return PlayerCommands